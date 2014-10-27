defmodule PlugJwtRouterTest do
  use ExUnit.Case, async: true
  use Plug.Test
  
  defmodule TestRouterPlug do
    import Plug.Conn
    use Plug.Router

    def verify(_payload), do: true
    
    plug PlugJwt, secret: "secret", verify: &PlugJwtRouterTest.TestRouterPlug.verify/1
    plug :match
    plug :dispatch
  
    get "/" do
      conn
      |> put_resp_content_type("text/plain")
      |> send_resp(200, "Hello Tester")
    end
  end

  defp call(conn) do
    TestRouterPlug.call(conn, [])
  end

  test "Sends 401 when credentials are missing" do
    conn = conn(:get, "/") |> call
    assert conn.status == 401
    assert conn.resp_body == "{\"description\":\"Unauthorized\",\"error\":\"Unauthorized\",\"status_code\":401}"
  end

  test "Passes connection and assigns claims when JWT token is valid" do
    payload = %{ sub: 1234567890, name: "John Doe", admin: true }
    {:ok, token} = Joken.encode(payload, "secret", :HS256, %{})

    auth_header = "Bearer " <> token
    conn = conn(:get, "/", [], headers: [{"authorization", auth_header}]) |> call
    assert conn.status == 200
    assert conn.resp_body == "Hello Tester"
    assert conn.assigns.claims == %{admin: true, name: "John Doe", sub: 1234567890}
  end

  test "Send 401 when invalid token sent" do
    incorrect_credentials = "Bearer " <> "Not a token"
    conn = conn(:get, "/", [], headers: [{"authorization", incorrect_credentials}]) |> call
    assert conn.status == 401
    assert conn.resp_body == "{\"description\":\"Invalid JSON Web Token\",\"error\":\"Unauthorized\",\"status_code\":401}"
  end
end
