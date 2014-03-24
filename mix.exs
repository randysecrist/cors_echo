env = System.get_env("MIX_ENV") || "dev"
Code.append_path "deps/relex/_build/" <> env <> "/lib/relex/ebin"
Code.append_path "deps/pogo/_build/" <> env <> "/lib/pogo/ebin"

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
    [ applications: [:cowboy, :dynamo,
                     :json, :httpoison, :exlager,
                     :stdlib, :inets ],
      mod: { CORSEcho, [] },
      env: [
        config_prop_1: true,
        config_prop_2: false
      ]
    ]
  end

  defp deps do
    [
      { :cowboy, github: "extend/cowboy" },
      { :dynamo, "~> 0.1.0-dev", github: "elixir-lang/dynamo" },
      { :json, github: "cblage/elixir-json" },
      { :httpoison, github: "edgurgel/httpoison" },
      { :exlager, github: "khia/exlager" },
      { :relex, github: "yrashk/relex" },
      { :pogo, github: "onkel-dirtus/pogo" }
    ]
  end

  if Code.ensure_loaded?(Relex.Release) do
    defmodule Release do
      use Relex.Release
      use Pogo.Release

      def name, do: "cors_echo"
      def version, do: Mix.project[:version]
      def applications do
        [:pogo, Mix.project[:app] ]
      end
      def lib_dirs, do: ["deps"]
    end
  end
end
