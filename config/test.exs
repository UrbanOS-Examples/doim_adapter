use Mix.Config

config :doim_adapter, DoimAdapterWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :warn

config :doim_adapter,
  doim_credentials_key: "doim_credentials",
  secrets_endpoint: "http://vault:8200"
