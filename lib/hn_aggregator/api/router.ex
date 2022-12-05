defmodule HNAggregator.API.Router do
  @port 4040

  alias HNAggregator.API.HTTPController
  alias HNAggregator.API.WebSocketHandler

  def child_spec do
    Plug.Cowboy.child_spec(
      scheme: :http,
      plug: __MODULE__,
      options: [port: @port, dispatch: dispatch()]
    )
  end

  defp dispatch do
    [
      {:_,
       [
         {"/ws/[...]", WebSocketHandler, []},
         {:_, Plug.Cowboy.Handler, {HTTPController, []}}
       ]}
    ]
  end
end
