defmodule PlugJwt do
  @moduledoc """
    A JWT Plug

    Usage:

    ```
        #When reading from joken config block
        plug PlugJwt
        
        #or parameters can be set directly and override the configurations in the joken config block
        plug PlugJwt, secret_key: "secret", claims: %{aud: "spiderman"}, json_module: TestJsx, algorithm: :HS256
    ```

    Parameters:
    
    PlugJWT will attempt to read from your joken config block. Settings can also be placed on the Plug itself
    which overrides the joken configuration


    * secret_key: The secret used to encode and verify the token
    * json_module: The module that implements Joken.Codec
    * algorithm (optional): The algorithm used to encode the token. Default: :HS256
    * claims (optional):  A map containing aud, iss, and sub values to verify if needed. Default: %{}
  """
  import Plug.Conn
  
  def init(opts) do
    secret = Keyword.get(opts, :secret_key, Application.get_env(:joken, :secret_key))
    json_module = Keyword.get(opts, :json_module, Application.get_env(:joken, :json_module))
    claims = Keyword.get(opts, :claims, Application.get_env(:joken, :claims, %{}))
    algorithm = Keyword.get(opts, :algorithm,  Application.get_env(:joken, :algorithm, :HS256))

    {secret, json_module, algorithm, claims}
  end

  def call(conn, config) do
    parse_auth(conn, get_req_header(conn, "authorization"), config)
  end

  defp parse_auth(conn, ["Bearer " <> token], {secret, json_module, algorithm, claims}) do
    case Joken.Token.decode(secret, json_module, token, algorithm, claims) do
      {:error, error} ->
        create_401_response(conn, error, json_module)
      {:ok, payload} ->
        conn |> assign(:claims, payload)      
    end
  end

  defp parse_auth(conn, _, {_secret, json_module, _algorithm, _claims}) do
    create_401_response(conn, "Unauthorized", json_module)
  end

  defp create_401_response(conn, description, json_module) do
    json = json_module.encode(%{error: "Unauthorized", description: description, status_code: 401})
    send_resp(conn, 401, json) |> halt
  end
end
