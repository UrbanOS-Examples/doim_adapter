defmodule DoimAdapter.SecretRetrieverLocal do
  @moduledoc """
  Retrieves secrets from environment variables.
  """

  @behaviour DoimAdapter.SecretRetriever

  @impl DoimAdapter.SecretRetriever
  def retrieve(_path) do
    {:ok,
     %{
       "username" => System.get_env("DOIM_USERNAME"),
       "password" => System.get_env("DOIM_PASSWORD")
     }}
  end
end
