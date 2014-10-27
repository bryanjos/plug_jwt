defmodule PlugJwt do
  @moduledoc """
    A JWT Plug

    Usage:

    ```
        plug PlugJwt, secret: "secret", verify: &verify_function/1, claims: %{aud: "spiderman"}
    ```

    Parameters:

    * secret: The secret used to encode and verify the token

    * verify: A function that takes the payload and verifies it's ok (i.e. make sure username is valid, etc)

    * claims (optional):  A map containing aud, iss, and sub values to verify if needed. Default: %{}
  """
  import Plug.Conn
  
  def init(opts) do
    secret = Keyword.fetch!(opts, :secret)
    verify = Keyword.fetch!(opts, :verify)
    claims = Keyword.get(opts, :claims, %{})
    {secret, verify, claims}
  end

  def call(conn, config) do
    parse_auth(conn, get_req_header(conn, "authorization"), config)
  end

  defp parse_auth(conn, ["Bearer " <> token], {secret, fun, claims}) do
    case Joken.decode(token, secret, claims) do
      {:error, error} ->
        create_401_response(conn, error)
      {:ok, payload} -> 
        case fun.(payload) do
          true ->
            conn |> assign(:claims, payload)
          false ->
            create_401_response(conn, "Unauthorized")
        end
    end
  end

  defp parse_auth(conn, _, _) do
    create_401_response(conn, "Unauthorized")
  end

  defp create_401_response(conn, description) do
    json = Jazz.encode!(%{error: "Unauthorized", description: description, status_code: 401})
    send_resp(conn, 401, json) |> halt
  end
end
