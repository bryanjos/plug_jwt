defmodule PlugJwt do

  import Plug.Conn, only: [get_req_header: 2, put_resp_header: 3, send_resp: 3, halt: 1]
  
  def init(opts) do
    secret = Keyword.fetch!(opts, :secret)
    verifyFun = Keyword.fetch!(opts, :verify)
    {secret, verifyFun}
  end

  def call(conn, {secret, fun}) do
    conn
    |> get_auth_header
    |> parse_auth(secret, fun)
  end

  defp get_auth_header(conn) do
    auth = get_req_header(conn, "authorization")
    {conn, auth}
  end

  defp parse_auth({conn, ["Bearer " <> token]}, secret, fun) do
    {status, payload_or_error} = Joken.decode(token, secret)
    case status do
      :error -> create_401_response(conn, payload_or_error)
      :ok -> verify_payload(conn, payload_or_error, fun)
    end
  end

  defp parse_auth({conn, _}, _, _) do
    create_401_response(conn, "Unauthorized")
  end

  defp verify_payload(conn, payload, fun) do
    case fun.(payload) do
      false -> send_resp(conn, 401, "Unauthorized") |> halt
      true -> conn
    end
  end

  defp create_401_response(conn, description) do
    json = Jazz.encode!(%{error: "Unauthorized", description: description, status_code: 401})
    send_resp(conn, 401, json) |> halt
  end
end
