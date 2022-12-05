defmodule HNAggregator.Worker do
  @moduledoc """
  GenServer process that periodically retrieves the top stories from Hacker News
  and stores them in an ETS table for later use.
  """

  use GenServer

  require Logger

  # Client

  def start_link(_opts) do
    opts = [
      table: HNAggregator.table_name(),
      delay: HNAggregator.worker_delay(),
      count: HNAggregator.top_stories_count()
    ]

    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  # GenServer callbacks

  @impl true
  def init(table: table, delay: delay, count: count) do
    create_ets_table(table)
    fetch_top_stories(count, delay)
    {:ok, table}
  end

  @impl true
  def handle_info({:fetch_top_stories, count, delay}, table) do
    fetch_top_stories(count, delay)
    maybe_cleanup_table(table, count)
    HNAggregator.refresh_websocket_data()

    {:noreply, table}
  end

  # The task completed successfully
  def handle_info({ref, {story_id, story}}, table) do
    # DOWN message can be ignored.
    Process.demonitor(ref, [:flush])
    :ets.insert(table, {story_id, story})

    {:noreply, table}
  end

  # Ignore if story retrieval task failed
  def handle_info({:DOWN, _ref, :process, _pid, _reason}, table) do
    {:noreply, table}
  end

  defp fetch_top_stories(count, delay) do
    HNAggregator.retrieve_top_stories(count)
    Process.send_after(self(), {:fetch_top_stories, count, delay}, delay)
  end

  defp create_ets_table(name) do
    case :ets.info(name) do
      :undefined ->
        :ets.new(name, [:named_table, read_concurrency: true])

      info ->
        Keyword.get(info, :name)
    end
  end

  defp maybe_cleanup_table(table, count) do
    table_size = :ets.info(table)[:size]

    if table_size >= count do
      table
      |> :ets.tab2list()
      |> Enum.sort_by(fn {k, _v} -> k end)
      |> Enum.take(table_size - count)
      |> Enum.each(fn {k, _v} ->
        :ets.delete(table, k)
      end)

      Logger.info("Finished cleaning up #{table} table")
    end
  end
end
