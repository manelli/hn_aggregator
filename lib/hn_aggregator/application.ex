defmodule HNAggregator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      HNAggregator.API.Router.child_spec(),
      HNAggregator.Worker,
      Registry.child_spec(name: Registry.HNAggregator, keys: :duplicate)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HNAggregator.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
