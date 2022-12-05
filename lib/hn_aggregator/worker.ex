defmodule HNAggregator.Worker do
  use GenServer

  # Client

  def start_link(opts = [table: _, delay: _, count: _]) do
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

    {:noreply, table}
  end

  defp fetch_top_stories(count, delay) do
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
end
