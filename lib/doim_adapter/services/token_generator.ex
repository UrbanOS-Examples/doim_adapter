defmodule DoimAdapter.TokenGenerator do
  @moduledoc """
  Generates a token by sending stored username and password to esri's generateToken endpoint.
  """
  @generate_token_headers ["Content-Type": "application/x-www-form-urlencoded"]

  require Logger

  def generate_token() do
    with {:ok, %{"username" => username, "password" => password}} <-
           secret_retriever().retrieve(doim_credentials_retrieval_key()),
         {:ok, _token} = response <- call_generate_token(username, password) do
      response
    else
      error ->
        Logger.error("Unable to generate token: #{inspect(error)}")
        error
    end
  end

  defp call_generate_token(username, password) do
    body = URI.encode_query(%{"username" => username, "password" => password})
    response = HTTPoison.post(generate_token_url(), body, @generate_token_headers)

    case response do
      {:ok, %{body: token, status_code: 200}} ->
        {:ok, token}

      {:ok, %{body: body, status_code: status_code}} ->
        {:error, "Unable to retrieve token. Got #{status_code} response: #{inspect(body)}"}

      error ->
        error
    end
  end

  defp generate_token_url() do
    Application.get_env(:doim_adapter, :generate_token_endpoint)
  end

  defp doim_credentials_retrieval_key() do
    Application.get_env(:doim_adapter, :doim_credentials_key)
  end

  defp secret_retriever() do
    Application.get_env(:doim_adapter, :secret_retriever)
  end
end
