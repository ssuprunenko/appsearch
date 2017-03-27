use Mix.Config

# Use Timber as the logger backend
# Feel free to add additional backends if you want to send you logs to multiple devices.
config :logger,
  backends: [Timber.LoggerBackend]

# Deliver logs via HTTP to the Timber API
config :timber,
  transport: Timber.Transports.HTTP,
  api_key: {:system, "TIMBER_LOGS_KEY"},
  http_client: Timber.Transports.HTTP.HackneyClient

# For dev / test environments, always log to STDOUt and format the logs properly
if Mix.env() == :dev || Mix.env() == :test do
  config :timber, transport: Timber.Transports.IODevice

  config :timber, :io_device,
    colorize: true,
    format: :logfmt,
    print_timestamps: true,
    print_log_level: true,
    print_metadata: false # turn this on to view the additiional metadata
end

# Need help?
# Email us: support@timber.io
# File an issue: https://github.com/timberio/timber-elixir/issues
