defmodule CORSEcho.Mixfile do
  use Mix.Project

  @version "0.0.2"

  def project do
    [
      app: :cors_echo,
      version: @version,
      elixir: "~> 1.8",
      start_permaanent: Mix.env == :prod,
      erlc_paths: ["lib"],
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      dialyzer_warnings: [
       :unmatched_returns,
       :error_handling,
       :race_conditions,
       :underspecs,
       :unknown],
      dialyzer_ignored_warnings: [
       {:warn_contract_supertype, :_, :_}
      ]
    ]
  end

  def version do
    @version
  end

  # Configuration for the OTP application
  def application do
    [
      applications: [],
      extra_applications: [
        :logger, :ranch
      ],
      mod: { CORSEcho, [] },
      included_applications: [],
    ]
  end

  defp deps do
    [
      {:communication_tools, git: "git@gitlab.com:sofiinc/comm/communication-tools", app: false},
      {:cowboy, github: "ninenines/cowboy", tag: "2.6.3"},
      {:cowlib, github: "ninenines/cowlib", tag: "2.7.3", override: true},
      {:ranch, github: "ninenines/ranch", ref: "1.7.1", override: true},
      {:jason, "~> 1.1.2"},
      {:observer_cli, "~> 1.4.2"},
      {:distillery, "~> 2.0.12"},
      {:meck, "~> 0.8.13", runtime: false, override: true},
      {:gun, "~> 1.3.0", override: true},
      {:faker, "~> 0.12.0"},
      {:dialyzex, "~> 1.2.1", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.10.6", only: :test}
    ]
  end
end
