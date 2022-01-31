use Mix.Config

config :doim_adapter, DoimAdapterWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "D6cZMvJJruawUj/bQ5LoEERSqb8ntBbbFFFpaZoBRCTTqt2Wo/dL//pPfZZpyHXc",
  render_errors: [view: DoimAdapterWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: DoimAdapter.PubSub, adapter: Phoenix.PubSub.PG2]

config :doim_adapter,
  secret_retriever: DoimAdapter.SecretRetrieverVault

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"
