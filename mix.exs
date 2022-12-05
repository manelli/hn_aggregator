defmodule HNAggregator.MixProject do
  use Mix.Project

  def project do
    [
      app: :hn_aggregator,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {HNAggregator.Application, []},
      registered: [HNAggregator.Worker]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 2.9"},
      {:jason, "~> 1.4"},
      {:plug, "~> 1.14"},
      {:plug_cowboy, "~> 2.6"},
      {:tesla, "~> 1.4"}
    ]
  end
end
