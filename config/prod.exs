use Mix.Config

config :doim_adapter, DoimAdapterWeb.Endpoint,
  http: [:inet6, port: 4000],
  server: true,
  root: ".",
  version: Application.spec(:doim_adapter, :vsn)

config :logger, level: :info
