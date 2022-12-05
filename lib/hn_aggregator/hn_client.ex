defmodule HNAggregator.HNClient do
  use Tesla
  require Logger

  @hn_api_url "https://hacker-news.firebaseio.com/v0"

  plug(Tesla.Middleware.BaseUrl, @hn_api_url)
  plug(Tesla.Middleware.JSON)

  def top_stories(count) do
    with {:ok, %{body: item_ids, status: 200}} <- get("/topstories.json"),
         top_n_item_ids <- Enum.take(item_ids, count),
         {:ok, supervisor} <- Task.Supervisor.start_link() do
      Enum.each(top_n_item_ids, fn item_id -> retrieve_item_task(item_id, supervisor) end)
    else
      _ -> Logger.error("Unable to retrieve top stories")
    end
  end

  # https://hexdocs.pm/elixir/1.14.2/Task.Supervisor.html#async_nolink/3-compatibility-with-otp-behaviours
  defp retrieve_item_task(item_id, supervisor) do
    Task.Supervisor.async_nolink(supervisor, fn ->
      {:ok, %{body: item, status: 200}} = get("/item/#{item_id}.json")
      {item_id, item}
    end)
  end
end
