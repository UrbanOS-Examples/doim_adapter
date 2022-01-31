defmodule DoimAdapterWeb.Router do
  use DoimAdapterWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]
  end

  scope "/api/v1", DoimAdapterWeb do
    get "/healthcheck", HealthCheckController, :index
  end

  scope "/api/v1", DoimAdapterWeb do
    pipe_through :api

    get "/work-orders", WorkOrdersController, :work_orders
    get "/work-resources", WorkOrdersController, :work_resources
    get "/work-tasks", WorkOrdersController, :work_tasks
  end
end
