defmodule DoimAdapterWeb.WorkOrdersController do
  use DoimAdapterWeb, :controller
  alias DoimAdapter.TokenGenerator

  require Logger

  def work_orders(conn, %{"range_start" => range_start, "range_end" => range_end}) do
    fetch(
      conn,
      work_orders_url(),
      "WO_MOD_DT BETWEEN DATE '#{range_start}' AND DATE '#{range_end}'"
    )
  end

  def work_resources(conn, %{"range_start" => range_start, "range_end" => range_end}) do
    fetch(
      conn,
      work_resources_url(),
      "WR_MOD_DT BETWEEN DATE '#{range_start}' AND DATE '#{range_end}'"
    )
  end

  def work_tasks(conn, %{"range_start" => range_start, "range_end" => range_end}) do
    fetch(
      conn,
      work_tasks_url(),
      "WT_MOD_DT BETWEEN DATE '#{range_start}' AND DATE '#{range_end}'"
    )
  end

  defp fetch(conn, endpoint_url, where_clause) do
    Logger.debug("Fetching from #{endpoint_url} with \"#{where_clause}\"")

    case TokenGenerator.generate_token() do
      {:ok, token} ->
        fetch(conn, endpoint_url, where_clause, token)

      {:error, reason} ->
        conn |> put_status(500) |> json("Unable to generate token: #{inspect(reason)}")
    end
  end

  defp fetch(conn, endpoint_url, where_clause, token) do
    headers = ["Content-Type": "application/json", Authorization: "Bearer #{token}"]

    query_params = %{
      "where" => where_clause,
      "outFields" => "*",
      "returnGeometry" => "false",
      "f" => "json"
    }

    response = HTTPoison.get(endpoint_url, headers, params: query_params)
    Logger.debug("Response from #{endpoint_url}: #{inspect(response)}")
    handle_response(response, conn)
  end

  defp handle_response({:ok, %{status_code: 200, body: body} = response}, conn) do
    with {:ok, decoded} <- Jason.decode(body),
         {:ok, features} <- get_features(decoded) do
      attributes = Enum.map(features, & &1["attributes"])
      json(conn, attributes)
    else
      _ ->
        proxy_failed_response(conn, response)
    end
  end

  defp handle_response({:ok, response}, conn) do
    proxy_failed_response(conn, response)
  end

  defp handle_response({:error, reason}, conn) do
    conn |> put_status(500) |> json("Unable to connect to underlying API: #{inspect(reason)}")
  end

  defp get_features(%{"features" => features}), do: {:ok, features}
  defp get_features(_), do: {:error, "Response did not contain features"}

  defp proxy_failed_response(conn, response) do
    conn
    |> merge_resp_headers(response.headers)
    |> send_resp(response.status_code, response.body)
  end

  defp work_orders_url(), do: Application.get_env(:doim_adapter, :work_orders_endpoint)

  defp work_resources_url(), do: Application.get_env(:doim_adapter, :work_resources_endpoint)

  defp work_tasks_url(), do: Application.get_env(:doim_adapter, :work_tasks_endpoint)
end
