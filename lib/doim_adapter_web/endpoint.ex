defmodule DoimAdapterWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :doim_adapter

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_doim_adapter_key",
    signing_salt: "<signing salt here>"

  plug DoimAdapterWeb.Router
end
