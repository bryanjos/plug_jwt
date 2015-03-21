defmodule PlugJwt do
  @moduledoc """
    A JWT Plug

    Usage:

    ```
        plug PlugJwt, secret: "secret", claims: %{aud: "spiderman"}, json_module: TestJsx
    ```

    Parameters:

    * secret: The secret used to encode and verify the token
    * json_module: The module that implements Joken.Codec
    * claims (optional):  A map containing aud, iss, and sub values to verify if needed. Default: %{}
  """
  import Plug.Conn
  
  def init(opts) do
    secret = Keyword.fetch!(opts, :secret)
    json_module = Keyword.fetch!(opts, :json_module)
    claims = Keyword.get(opts, :claims, %{})

    {secret, json_module, claims}
  end

  def call(conn, config) do
    parse_auth(conn, get_req_header(conn, "authorization"), config)
  end

  defp parse_auth(conn, ["Bearer " <> token], {secret, json_module, claims}) do
    case Joken.Token.decode(secret, json_module, token, claims) do
      {:error, error} ->
        create_401_response(conn, error, json_module)
      {:ok, payload} ->
        conn |> assign(:claims, payload)      
    end
  end

  defp parse_auth(conn, _, {_secret, json_module, _claims}) do
    create_401_response(conn, "Unauthorized", json_module)
  end

  defp create_401_response(conn, description, json_module) do
    json = json_module.encode(%{error: "Unauthorized", description: description, status_code: 401})
    send_resp(conn, 401, json) |> halt
  end
end
