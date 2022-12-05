defmodule HNAggregator do
  @moduledoc """
  HN Aggregator context.

  This module contains functions used across the whole application.
  It also contains functions that specify hardcoded variables that work as configuration.
  (This could be improved by using Config files).
  """

  alias HNAggregator.API.WebSocketHandler
  alias HNAggregator.HNClient

  @spec table_name() :: atom()
  def table_name, do: :top_stories

  @spec worker_delay() :: integer()
  def worker_delay, do: :timer.minutes(5)

  @spec top_stories_count() :: pos_integer()
  def top_stories_count, do: 50

  @spec retrieve_top_stories(pos_integer()) :: :ok
  def retrieve_top_stories(count), do: HNClient.top_stories(count)

  @spec list_stories() :: list(tuple())
  def list_stories, do: table_name() |> :ets.tab2list()

  @spec find_story(pos_integer()) :: {:ok, iodata()} | {:error, term()}
  def find_story(id) do
    table_name()
    |> :ets.lookup(id)
    |> case do
      [{_id, story}] -> Jason.encode_to_iodata(story)
      _ -> {:error, :not_found}
    end
  end

  @spec refresh_websocket_data() :: :ok
  def refresh_websocket_data() do
    list_stories()
    |> Enum.into(%{})
    |> Jason.encode_to_iodata!()
    |> WebSocketHandler.send()
  end
end
