use Mix.Config

config :cors_echo,
  [
    network: [
      {:protocol, :http},
      {:bind, {'0.0.0.0', 19090}},
      {:acceptors, System.schedulers_online * 2},
    ]
  ]

config :logger,
  backends: [
    {FileLoggerBackend, :error_log},
    {FileLoggerBackend, :access_log}]

config :logger, :access_log,
  level: :info,
  path: File.cwd! <> "/log/access.log",
  metadata: [:function, :module, :line]

config :logger, :error_log,
  level: :error,
  path: File.cwd! <> "/log/error.log",
  metadata: [:function, :module, :line]
