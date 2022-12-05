defmodule HNAggregator.HNClient do
  @moduledoc """
  HTTP Client for the Hacker News API

  See: https://github.com/HackerNews/API
  """
  use Tesla
  require Logger

  @hn_api_url "https://hacker-news.firebaseio.com/v0"

  plug(Tesla.Middleware.BaseUrl, @hn_api_url)
  plug(Tesla.Middleware.JSON)

  @spec top_stories(pos_integer()) :: :ok
  def top_stories(count) do
    with {:ok, %{body: item_ids, status: 200}} <- get("/topstories.json"),
         top_n_item_ids <- Enum.take(item_ids, count),
         {:ok, supervisor} <- Task.Supervisor.start_link() do
      Enum.each(top_n_item_ids, fn item_id -> retrieve_item_task(item_id, supervisor) end)
    else
      _ -> Logger.error("Unable to retrieve top stories")
    end
  end

  @spec retrieve_item_task(pos_integer(), Supervisor.supervisor()) :: Task.t()
  defp retrieve_item_task(item_id, supervisor) do
    # async_nolink is used because it is called from a GenServer
    # See: https://hexdocs.pm/elixir/1.14.2/Task.Supervisor.html#async_nolink/3-compatibility-with-otp-behaviours
    Task.Supervisor.async_nolink(supervisor, fn ->
      {:ok, %{body: item, status: 200}} = get("/item/#{item_id}.json")
      {item_id, item}
    end)
  end
end
