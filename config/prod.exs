import Config

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :oliya, OliyaWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")],
  secret_key_base: secret_key_base,
  url: [host: System.get_env("PHX_HOST"), port: 80],
  force_ssl: [
    host: nil,
    rewrite_on: [:x_forwarded_port, :x_forwarded_proto],
    # maybe true when we use this for real
    hsts: false
  ],
  server: true

# Do not print debug messages in production
config :logger, level: :info

config :tai,
  broadcast_change_set: true,
  venues: %{
    bitmex: [
      enabled: true,
      adapter: Tai.VenueAdapters.Bitmex,
      products: "xbtusd",
      timeout: 60_000,
      channels: [:trades]
    ],
    binance: [
      enabled: true,
      adapter: Tai.VenueAdapters.Binance,
      products: "btc_usdt",
      channels: [:trades]
    ]
  }
