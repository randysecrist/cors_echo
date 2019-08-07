use Mix.Config

config :ssl, protocol_version: :"tlsv1.2"

config :logger,
  utc_log: true,
  compile_time_purge_matching: [
    [level_lower_than: :info]
  ],
  mode: :async,
  truncate: 4096,
  async_threshold: 75,
  sync_threshold: 100,
  discard_threshold: 300,
  handle_otp_reports: true,
  handle_sasl_reports: false

# if a process decides to have a uuid cache
config :quickrand,
  cache_size: 65536

config :distillery,
  no_warn_missing: [
    :meck,
  ]

import_config "#{Mix.env}.exs"
import_config "*local.exs"
