defmodule DoimAdapter.MixProject do
  use Mix.Project

  def project do
    [
      app: :doim_adapter,
      version: "0.1.0",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {DoimAdapter.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:bypass, "~> 1.0", only: [:test, :integration]},
      {:distillery, "2.0.14"},
      {:gettext, "~> 0.11"},
      {:httpoison, "~> 1.6"},
      {:jason, "~> 1.0"},
      {:libvault, "~> 0.2"},
      {:mix_test_watch, "~> 0.9", only: :dev, runtime: false},
      {:phoenix, "~> 1.4.11"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_pubsub, "~> 1.1"},
      {:placebo, "~> 1.2", only: [:test, :integration]},
      {:plug_cowboy, "~> 2.0"},
      {:tesla, "~> 1.3"}
    ]
  end
end
