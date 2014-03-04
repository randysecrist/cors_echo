defmodule CORSEcho.Mixfile do
  use Mix.Project

  def project do
    [ app: :cors_echo,
      version: "0.0.1",
      build_per_environment: true,
      dynamos: [CORSEcho.Dynamo],
      compilers: [:elixir, :dynamo, :app],
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [ applications: [:cowboy, :dynamo],
      mod: { CORSEcho, [] } ]
  end

  defp deps do
    [ { :cowboy, github: "extend/cowboy" },
      { :dynamo, "~> 0.1.0-dev", github: "elixir-lang/dynamo" },
      { :json, github: "cblage/elixir-json" },
      { :httpoison, github: "edgurgel/httpoison" }, ]
  end
end
