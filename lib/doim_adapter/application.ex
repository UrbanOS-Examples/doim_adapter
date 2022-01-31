defmodule DoimAdapter.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      DoimAdapterWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: DoimAdapter.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    DoimAdapterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
