defmodule PlugJwt do
  @moduledoc """
  A JWT Plug

  Usage:

      #When reading from joken config block
      plug PlugJwt
      
      #or the module that implements `Joken.Config` can be set explicitly
      plug PlugJwt, config_module: My.Joken.Config

      
  Parameters:
  
  PlugJWT will attempt to read from your joken config block. Settings can also be placed on the Plug itself
  which overrides the joken configuration

  * config_module: The module that implements Joken.Config
  """
  import Plug.Conn
  
  def init(opts) do
    config_module = Keyword.get(opts, :config_module, Application.get_env(:joken, :config_module))
    claims = Keyword.get(opts, :claims, [])
    {config_module, claims}
  end

  def call(conn, config) do
    parse_auth(conn, get_req_header(conn, "authorization"), config)
  end

  defp parse_auth(conn, ["Bearer " <> token], {config_module, claims}) do
    case Joken.Token.decode(config_module, token) do
      {:error, error} ->
        create_401_response(conn, error, config_module)
      {:ok, payload} ->
        test_claims(payload, claims, conn, config_module)      
    end
  end

  defp parse_auth(conn, _, {config_module, _claims}) do
    create_401_response(conn, "Unauthorized", config_module)
  end

  defp test_claims(payload, claims, conn, config_module) do
    if Enum.all?(claims, fn({k,v})-> validate_claim(payload, k, v) == :ok end) do
      conn |> assign(:claims, payload)
    else
      create_401_response(conn, "Unauthorized", config_module)
    end
  end

  defp validate_claim(payload, claim_key, claim_value) do
    cond do
      Dict.get(payload, claim_key, nil) == claim_value ->
        :ok
      true ->
        :error
    end
  end

  defp create_401_response(conn, description, config_module) do
    json = config_module.encode(%{error: "Unauthorized", description: description, status_code: 401})
    send_resp(conn, 401, json) |> halt
  end
end
