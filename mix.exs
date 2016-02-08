defmodule Trueskill.Mixfile do
  use Mix.Project

  def project do
    [app: :trueskill,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     preferred_cli_env: [espec: :test],
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:statistics, "~> 0.4.0", git: "https://github.com/HidetakaKojo/elixir-statistics.git", tag: "master"},
      {:espec, "~> 0.8.5", only: :test}
    ]
  end
end
