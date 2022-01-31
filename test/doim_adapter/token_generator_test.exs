defmodule TokenGeneratorTest do
  use ExUnit.Case
  use Placebo

  alias DoimAdapter.TokenGenerator
  alias DoimAdapter.SecretRetrieverVault

  @credentials %{"username" => "philly", "password" => "cheesesteak"}
  @credentials_retrieval_key Application.get_env(:doim_adapter, :doim_credentials_key)

  @moduletag capture_log: true
  describe "generate_token/1" do
    setup do
      bypass = Bypass.open()

      Application.put_env(
        :doim_adapter,
        :generate_token_endpoint,
        "http://localhost:#{bypass.port}/generate-token"
      )

      %{bypass: bypass}
    end

    test "calls to generate token using stored username and password", %{bypass: bypass} do
      token = "token"

      allow(SecretRetrieverVault.retrieve(@credentials_retrieval_key), return: {:ok, @credentials})

      Bypass.expect(bypass, fn conn ->
        assert conn.method == "POST"

        assert "application/x-www-form-urlencoded" in Plug.Conn.get_req_header(
                 conn,
                 "content-type"
               )

        assert {:ok, body, _} = Plug.Conn.read_body(conn)
        assert %{"username" => username, "password" => password} = URI.decode_query(body)
        assert username == @credentials["username"]
        assert password == @credentials["password"]

        Plug.Conn.resp(conn, :ok, token)
      end)

      assert TokenGenerator.generate_token() == {:ok, token}
    end

    test "returns error when stored credentials cannot be retrieved" do
      secret_retrieval_response = {:error, "no creds for you"}
      allow(SecretRetrieverVault.retrieve(any()), return: secret_retrieval_response)

      assert TokenGenerator.generate_token() == secret_retrieval_response
    end

    test "returns error when generate token API responds with an error", %{bypass: bypass} do
      allow(SecretRetrieverVault.retrieve(@credentials_retrieval_key), return: {:ok, @credentials})

      Bypass.stub(bypass, "POST", "/generate-token", fn conn ->
        Plug.Conn.resp(conn, 401, "no token for you")
      end)

      assert {:error, _} = TokenGenerator.generate_token()
    end

    test "returns error when generate token does not respond", %{bypass: bypass} do
      allow(SecretRetrieverVault.retrieve(@credentials_retrieval_key), return: {:ok, @credentials})

      Bypass.down(bypass)

      assert {:error, _} = TokenGenerator.generate_token()
    end
  end
end
