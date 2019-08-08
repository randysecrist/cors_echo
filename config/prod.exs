use Mix.Config

config :cors_echo,
  [
    network: [
      {:protocol, :http},
      {:bind, {'0.0.0.0', 80}},
      {:acceptors, System.schedulers_online * 2},
    ]
  ]

config :logger,
  backends: [
    :console,
    {FileLoggerBackend, :error_log}
  ]

config :logger, :console,
  level: :info,
  metadata: [:function, :module, :line]

config :logger, :error_log,
  level: :error,
  path: File.cwd! <> "/log/error.log",
  metadata: [:function, :module, :line]
