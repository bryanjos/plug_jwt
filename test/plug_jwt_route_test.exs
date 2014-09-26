defmodule PlugJwtRouteTest do
  use ExUnit.Case, async: true
  use Plug.Test
  
  defmodule TestRoutePlug do
    import Plug.Conn
    use Plug.Router

    def verify(payload), do: true

    plug :match
    plug :dispatch
  
    get "/" do
      conn
      |> PlugJwt.call({"secret", &PlugJwtRouteTest.TestRoutePlug.verify/1})
      |> send_resp(200, "Hello Tester")
    end
  end

  defp call(conn) do
    TestRoutePlug.call(conn, [])
  end

  test "Sends 401 when credentials are missing" do
    conn = conn(:get, "/") |> call
    assert conn.status == 401
    assert conn.resp_body == "{\"description\":\"Unauthorized\",\"error\":\"Unauthorized\",\"status_code\":401}"
  end

  test "Passes connection when JWT token is valid" do
    payload = %{ sub: 1234567890, name: "John Doe", admin: true }
    {:ok, token} = Joken.encode(payload, "secret", :HS256, %{})

    auth_header = "Bearer " <> token
    conn = conn(:get, "/", [], headers: [{"authorization", auth_header}]) |> call
    assert conn.status == 200
    assert conn.resp_body == "Hello Tester"
  end

  test "Send 401 when invalid token sent" do
    incorrect_credentials = "Bearer " <> "Not a token"
    conn = conn(:get, "/", [], headers: [{"authorization", incorrect_credentials}]) |> call
    assert conn.status == 401
    assert conn.resp_body == "{\"description\":\"Invalid JSON Web Token\",\"error\":\"Unauthorized\",\"status_code\":401}"
  end
end
