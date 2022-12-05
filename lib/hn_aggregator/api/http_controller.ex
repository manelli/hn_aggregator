defmodule HNAggregator.API.HTTPController do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/stories" do
    json(conn, 200, HNAggregator.list_stories())
  end

  get "/stories/:id" do
    id
    |> String.to_integer()
    |> HNAggregator.find_story()
    |> case do
      {:ok, story} -> json(conn, 200, story)
      {:error, :not_found} -> send_resp(conn, 404, "Not Found")
      _ -> send_resp(conn, 500, "Something went wrong")
    end
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

  defp json(conn, status, data) do
    conn
    |> Plug.Conn.put_resp_header("Content-Type", "application/json")
    |> send_resp(status, data)
  end
end
