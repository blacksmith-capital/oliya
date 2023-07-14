# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :oliya, ecto_repos: [Oliya.Backend.Postgres.Repo]

config :oliya, Oliya.Backend.Postgres.Repo,
  username: {:system, "POSTGRES_USER", "postgres"},
  password: {:system, "POSTGRES_PASSWORD", "postgres"},
  database: {:system, "POSTGRES_DB", "oliya_dev"},
  hostname: {:system, "POSTGRES_HOST", "localhost"},
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# Configures the endpoint
config :oliya, OliyaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "SgXgylgGEwMBEiPY5Wrsg3qXAWZgfB8D+Fkd7Sy9uRer1rm8Ttdqbj6+cM1BK5Re",
  render_errors: [view: OliyaWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Oliya.PubSub,
  live_view: [signing_salt: "SgXgylgGEwMBEiPY5Wrsg3qXAWZgfB8D+Fkd7Sy9uRer1rm8Ttdqbj6+cM1BK5Re"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
