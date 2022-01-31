defmodule DoimAdapter.SecretRetrieverVaultTest do
  use ExUnit.Case
  use Placebo
  alias DoimAdapter.SecretRetrieverVault
  import ExUnit.CaptureLog

  describe "retrieve/1" do
    setup do
      credentials = %{"username" => "admin", "password" => "1234"}

      %{
        secret_id: 1,
        role: "doim-role",
        jwt: "just-want-tokens",
        credentials: credentials,
        vault: %Vault{engine: :secrets_engine, host: "http://vault:8200", auth: :auth_backend}
      }
    end

    test "retrieves credentials for given secret_id", values do
      allow(File.read("/var/run/secrets/kubernetes.io/serviceaccount/token"),
        return: {:ok, values.jwt}
      )

      allow(Vault.new(any()), return: values.vault)

      allow(Vault.auth(values.vault, %{role: values.role, jwt: values.jwt}),
        return: {:ok, values.vault}
      )

      allow(Vault.read(values.vault, "secrets/smart_city/doim/#{values.secret_id}"),
        return: {:ok, values.credentials}
      )

      assert SecretRetrieverVault.retrieve(values.secret_id) == {:ok, values.credentials}
    end

    test "returns error when kubernetes token file is not found", values do
      allow(File.read("/var/run/secrets/kubernetes.io/serviceaccount/token"),
        return: {:error, :enoent}
      )

      assert capture_log(fn ->
               assert SecretRetrieverVault.retrieve(values.secret_id) ==
                        {:error, :retrieve_credential_failed}
             end) =~ "Secret token file not found"
    end

    test "returns error when vault service is unavailable", values do
      allow(File.read("/var/run/secrets/kubernetes.io/serviceaccount/token"),
        return: {:ok, values.jwt}
      )

      allow(Vault.new(any()), return: values.vault)

      allow(Vault.auth(values.vault, %{role: values.role, jwt: values.jwt}),
        return: {:error, ["Something bad happened"]}
      )

      assert capture_log(fn ->
               assert SecretRetrieverVault.retrieve(values.secret_id) ==
                        {:error, :retrieve_credential_failed}
             end) =~ "Something bad happened"
    end
  end
end
