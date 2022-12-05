defmodule HNAggregator.API.WebSocketHandler do
  @behaviour :cowboy_websocket

  @registry_key :stories

  def send(data) do
    Registry.dispatch(Registry.HNAggregator, @registry_key, fn procs ->
      Enum.each(procs, fn {pid, _} ->
        Process.send(pid, data, [])
      end)
    end)
  end

  @impl true
  def init(request, _state) do
    {:cowboy_websocket, request, @registry_key}
  end

  @impl true
  def websocket_init(key) do
    Registry.register(Registry.HNAggregator, key, {})
    {:ok, key}
  end

  @impl true
  def websocket_handle(_in_frame, key) do
    {:ok, key}
  end

  @impl true
  def websocket_info(info, state) do
    {:reply, {:text, info}, state}
  end
end
