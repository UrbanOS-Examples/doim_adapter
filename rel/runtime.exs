use Mix.Config

required_envars = [
  "PORT",
  "DOIM_CREDENTIALS_KEY",
  "DOIM_GENERATE_TOKENS_ENDPOINT",
  "DOIM_WORK_ORDERS_ENDPOINT",
  "DOIM_WORK_RESOURCES_ENDPOINT",
  "DOIM_WORK_TASKS_ENDPOINT",
  "SECRETS_ENDPOINT"
]

Enum.each(required_envars, fn var ->
  if is_nil(System.get_env(var)) do
    raise ArgumentError, message: "Required environment variable #{var} is undefined"
  end
end)

config :doim_adapter, DoimAdapterWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")]

config :doim_adapter,
  doim_credentials_key: System.get_env("DOIM_CREDENTIALS_KEY"),
  generate_token_endpoint: System.get_env("DOIM_GENERATE_TOKENS_ENDPOINT"),
  work_orders_endpoint: System.get_env("DOIM_WORK_ORDERS_ENDPOINT"),
  work_resources_endpoint: System.get_env("DOIM_WORK_RESOURCES_ENDPOINT"),
  work_tasks_endpoint: System.get_env("DOIM_WORK_TASKS_ENDPOINT"),
  secrets_endpoint: System.get_env("SECRETS_ENDPOINT")
