import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :oliya, OliyaWeb.Endpoint,
  http: [port: 4002],
  server: false

config :oliya, Oliya.Backend.Postgres.Repo,
  username: {:system, "POSTGRES_USER", "postgres"},
  password: {:system, "POSTGRES_PASSWORD", "postgres"},
  database: {:system, "POSTGRES_DB", "oliya_test"},
  hostname: {:system, "POSTGRES_HOST", "localhost"},
  pool: Ecto.Adapters.SQL.Sandbox

# Print only warnings and errors during test
config :logger, :file_log, path: "./log/#{Mix.env()}.log"
config :logger, backends: [{LoggerFileBackend, :file_log}]
