# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :pikiri,
  ecto_repos: [Pikiri.Repo],
  uploads_directory: "uploads"

# Configures the endpoint
host = System.get_env("PHX_HOST") || "localhost"
port = String.to_integer(System.get_env("PORT") || "4000")

config :pikiri, PikiriWeb.Endpoint,
  url: [host: host, port: port],
  render_errors: [view: PikiriWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Pikiri.PubSub,
  live_view: [signing_salt: "VlO4kbad"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :pikiri, Pikiri.Mailer,
  adapter: Swoosh.Adapters.SMTP,
  relay: System.get_env("SMTP_SERVER"),
  port: System.get_env("SMTP_PORT"),
  username: System.get_env("SMTP_USERNAME"),
  password: System.get_env("SMTP_PASSWORD"),
  tls: :always

config :pikiri, Pikiri.Guardian,
  issuer: "pikiri",
  secret_key: "V31AmclpyBV7Oftzex03shXBtQUP/MpKfNO5IzwRpaEps7foNTgF8l008jugyyJS",
  token_ttl: %{
    "magic" => {30, :minutes},
    "access" => {1, :week}
  }

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

config :waffle,
  storage: Waffle.Storage.Local,
  asset_host: {:system, "ASSET_HOST"}

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure icons
config :ex_fontawesome, type: "solid"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
