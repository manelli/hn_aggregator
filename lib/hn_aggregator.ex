defmodule HNAggregator do
  @moduledoc """
  Documentation for `HNAggregator`.
  """

  alias HNAggregator.API.WebSocketHandler
  alias HNAggregator.HNClient

  def table_name, do: :top_stories

  def worker_delay, do: :timer.minutes(5)

  def top_stories_count, do: 50

  def retrieve_top_stories(count), do: HNClient.top_stories(count)

  def list_stories do
    table_name() |> table_to_json()
  end

  def find_story(id) do
    table_name()
    |> :ets.lookup(id)
    |> case do
      [{_id, story}] -> Jason.encode_to_iodata(story)
      _ -> {:error, :not_found}
    end
  end

  def refresh_websocket_data() do
    list_stories() |> WebSocketHandler.send()
  end

  defp table_to_json(name) do
    name
    |> :ets.tab2list()
    |> Enum.into(%{})
    |> Jason.encode_to_iodata!()
  end
end
