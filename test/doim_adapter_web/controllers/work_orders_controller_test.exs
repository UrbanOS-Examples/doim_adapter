defmodule DoimAdapterWeb.WorkOrdersControllerTest do
  use DoimAdapterWeb.ConnCase
  use Placebo

  alias DoimAdapter.TokenGenerator

  @token "this-is-a-token"

  describe "GET /api/v1/work-orders" do
    setup do
      bypass = Bypass.open()

      Application.put_env(
        :doim_adapter,
        :work_orders_endpoint,
        "http://localhost:#{bypass.port}/api/v1/work-orders"
      )

      %{bypass: bypass}
    end

    test "fetches work orders with provided range parameters when token can be retrieved", %{
      conn: conn,
      bypass: bypass
    } do
      allow(TokenGenerator.generate_token(), return: {:ok, @token})

      expected = []
      response_body = %{"features" => expected}
      range_start = "2019-12-10"
      range_end = "2019-12-11"

      Bypass.expect(bypass, fn conn ->
        assert conn.method == "GET"

        assert "Bearer #{@token}" in Plug.Conn.get_req_header(conn, "authorization")
        assert "application/json" in Plug.Conn.get_req_header(conn, "content-type")

        query_params = Plug.Conn.fetch_query_params(conn) |> Map.get(:query_params)

        assert %{
                 "f" => "json",
                 "outFields" => "*",
                 "returnGeometry" => "false",
                 "where" => "WO_MOD_DT BETWEEN DATE '#{range_start}' AND DATE '#{range_end}'"
               } == query_params

        Plug.Conn.resp(conn, :ok, Jason.encode!(response_body))
      end)

      conn =
        get(conn, "/api/v1/work-orders", %{"range_start" => range_start, "range_end" => range_end})

      assert json_response(conn, 200) == expected
    end

    test "returns only the list of feature attributes when the underlying work orders are retrieved successfully",
         %{
           conn: conn,
           bypass: bypass
         } do
      allow(TokenGenerator.generate_token(), return: {:ok, @token})

      response_body = %{
        "features" => [
          %{"attributes" => %{"WO_ID" => 19102, "WO_NUMBER" => "13-002935"}},
          %{"attributes" => %{"WO_ID" => 19103, "WO_NUMBER" => "13-002936"}}
        ]
      }

      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, :ok, Jason.encode!(response_body))
      end)

      conn =
        get(conn, "/api/v1/work-orders", %{
          "range_start" => "2019-12-10",
          "range_end" => "2019-12-11"
        })

      expected = response_body["features"] |> Enum.map(fn feature -> feature["attributes"] end)
      assert json_response(conn, 200) == expected
    end

    test "returns the response from the underlying work orders API when status code is non-success",
         %{
           conn: conn,
           bypass: bypass
         } do
      allow(TokenGenerator.generate_token(), return: {:ok, @token})

      response_body = %{"you" => "failed"}

      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 400, Jason.encode!(response_body))
        |> put_resp_content_type("text/plain")
      end)

      conn =
        get(conn, "/api/v1/work-orders", %{
          "range_start" => "2019-12-10",
          "range_end" => "2019-12-11"
        })

      assert response(conn, 400) == Jason.encode!(response_body)
      assert response_content_type(conn, :text)
    end

    test "returns the response from the underlying work orders API when response does not contain features",
         %{
           conn: conn,
           bypass: bypass
         } do
      allow(TokenGenerator.generate_token(), return: {:ok, @token})

      response_body = %{"not_features" => []}

      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, Jason.encode!(response_body))
        |> put_resp_content_type("application/json")
      end)

      conn =
        get(conn, "/api/v1/work-orders", %{
          "range_start" => "2019-12-10",
          "range_end" => "2019-12-11"
        })

      assert response(conn, 200) == Jason.encode!(response_body)
      assert response_content_type(conn, :json)
    end

    test "returns internal server erro when the underlying work orders API does not respond", %{
      conn: conn,
      bypass: bypass
    } do
      allow(TokenGenerator.generate_token(), return: {:ok, @token})

      Bypass.down(bypass)

      conn =
        get(conn, "/api/v1/work-orders", %{
          "range_start" => "2019-12-10",
          "range_end" => "2019-12-11"
        })

      assert json_response(conn, 500) =~ "Unable to connect to underlying API"
    end

    test "returns internal server error when token cannot be retrieved", %{conn: conn} do
      allow(TokenGenerator.generate_token(), return: {:error, "nope"})

      conn =
        get(conn, "/api/v1/work-orders", %{
          "range_start" => "irrelevant",
          "range_end" => "don't matter"
        })

      assert json_response(conn, 500) =~ "nope"
    end
  end

  describe "GET /api/v1/work-resources" do
    setup do
      bypass = Bypass.open()

      Application.put_env(
        :doim_adapter,
        :work_resources_endpoint,
        "http://localhost:#{bypass.port}/api/v1/work-resources"
      )

      %{bypass: bypass}
    end

    test "fetches work resources with provided range parameters when token can be retrieved", %{
      conn: conn,
      bypass: bypass
    } do
      allow(TokenGenerator.generate_token(), return: {:ok, @token})

      expected = []
      response_body = %{"features" => expected}
      range_start = "2019-12-10"
      range_end = "2019-12-11"

      Bypass.expect(bypass, fn conn ->
        assert conn.method == "GET"

        assert "Bearer #{@token}" in Plug.Conn.get_req_header(conn, "authorization")
        assert "application/json" in Plug.Conn.get_req_header(conn, "content-type")

        query_params = Plug.Conn.fetch_query_params(conn) |> Map.get(:query_params)

        assert %{
                 "f" => "json",
                 "outFields" => "*",
                 "returnGeometry" => "false",
                 "where" => "WR_MOD_DT BETWEEN DATE '#{range_start}' AND DATE '#{range_end}'"
               } == query_params

        Plug.Conn.resp(conn, :ok, Jason.encode!(response_body))
      end)

      conn =
        get(conn, "/api/v1/work-resources", %{
          "range_start" => range_start,
          "range_end" => range_end
        })

      assert json_response(conn, 200) == expected
    end

    test "returns only the list of feature attributes when the underlying work orders are retrieved successfully",
         %{
           conn: conn,
           bypass: bypass
         } do
      allow(TokenGenerator.generate_token(), return: {:ok, @token})

      response_body = %{
        "features" => [
          %{"attributes" => %{"WR_ID" => 19102, "WR_RTYP_TY" => "Equipment"}},
          %{"attributes" => %{"WR_ID" => 19103, "WR_RTYP_TY" => "Material"}}
        ]
      }

      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, :ok, Jason.encode!(response_body))
      end)

      conn =
        get(conn, "/api/v1/work-resources", %{
          "range_start" => "2019-12-10",
          "range_end" => "2019-12-11"
        })

      expected = response_body["features"] |> Enum.map(fn feature -> feature["attributes"] end)
      assert json_response(conn, 200) == expected
    end
  end

  describe "GET /api/v1/work-tasks" do
    setup do
      bypass = Bypass.open()

      Application.put_env(
        :doim_adapter,
        :work_tasks_endpoint,
        "http://localhost:#{bypass.port}/api/v1/work-tasks"
      )

      %{bypass: bypass}
    end

    test "fetches work resources with provided range parameters when token can be retrieved", %{
      conn: conn,
      bypass: bypass
    } do
      allow(TokenGenerator.generate_token(), return: {:ok, @token})

      expected = []
      response_body = %{"features" => expected}
      range_start = "2019-12-10"
      range_end = "2019-12-11"

      Bypass.expect(bypass, fn conn ->
        assert conn.method == "GET"

        assert "Bearer #{@token}" in Plug.Conn.get_req_header(conn, "authorization")
        assert "application/json" in Plug.Conn.get_req_header(conn, "content-type")

        query_params = Plug.Conn.fetch_query_params(conn) |> Map.get(:query_params)

        assert %{
                 "f" => "json",
                 "outFields" => "*",
                 "returnGeometry" => "false",
                 "where" => "WT_MOD_DT BETWEEN DATE '#{range_start}' AND DATE '#{range_end}'"
               } == query_params

        Plug.Conn.resp(conn, :ok, Jason.encode!(response_body))
      end)

      conn =
        get(conn, "/api/v1/work-tasks", %{"range_start" => range_start, "range_end" => range_end})

      assert json_response(conn, 200) == expected
    end

    test "returns only the list of feature attributes when the underlying work orders are retrieved successfully",
         %{
           conn: conn,
           bypass: bypass
         } do
      allow(TokenGenerator.generate_token(), return: {:ok, @token})

      response_body = %{
        "features" => [
          %{"attributes" => %{"WT_ID" => 19102, "WR_TASK_TY" => "Stone Patching"}},
          %{"attributes" => %{"WT_ID" => 19103, "WR_RTYP_TY" => "Equipment Maintenance"}}
        ]
      }

      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, :ok, Jason.encode!(response_body))
      end)

      conn =
        get(conn, "/api/v1/work-tasks", %{
          "range_start" => "2019-12-10",
          "range_end" => "2019-12-11"
        })

      expected = response_body["features"] |> Enum.map(fn feature -> feature["attributes"] end)
      assert json_response(conn, 200) == expected
    end
  end
end
