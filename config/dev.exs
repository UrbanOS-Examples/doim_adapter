use Mix.Config

config :doim_adapter, DoimAdapterWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

config :doim_adapter, DoimAdapterWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"lib/doim_adapter_web/{live,views}/.*(ex)$",
      ~r"lib/doim_adapter_web/templates/.*(eex)$"
    ]
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime

config :doim_adapter,
  secret_retriever: DoimAdapter.SecretRetrieverLocal

config :doim_adapter,
  doim_credentials_key: "doim_credentials",
  generate_token_endpoint: "https://arc.columbus.gov/arcgis/tokens/generateToken",
  work_orders_endpoint:
    "https://arc.columbus.gov/arcgis/rest/services/Test/LucityWorkOrder/MapServer/1/query",
  work_resources_endpoint:
    "https://arc.columbus.gov/arcgis/rest/services/Test/LucityWorkOrder/MapServer/2/query",
  work_tasks_endpoint:
    "https://arc.columbus.gov/arcgis/rest/services/Test/LucityWorkOrder/MapServer/3/query"
