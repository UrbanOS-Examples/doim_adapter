defmodule DoimAdapter.SecretRetriever do
  @callback retrieve(String.t()) :: {:ok, map} | {:error, term}
end
