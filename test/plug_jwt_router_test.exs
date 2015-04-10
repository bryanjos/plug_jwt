defmodule PlugJwtRouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  defmodule TestJsx do
    alias :jsx, as: JSON
    @behaviour Joken.Codec

    def encode(map) do
      JSON.encode(map)
    end

    def decode(binary) do
      JSON.decode(binary)
      |> Enum.map(fn({key, value})-> {String.to_atom(key), value} end)
    end
  end
  
  defmodule TestRouterPlug do
    import Plug.Conn
    use Plug.Router
    
    plug PlugJwt, secret_key: "secret", json_module: TestJsx
    plug :match
    plug :dispatch
  
    get "/" do
      conn
      |> put_resp_content_type("text/plain")
      |> send_resp(200, "Hello Tester")
    end
  end

  defmodule TestRouterPlugFromConfig do
    import Plug.Conn
    use Plug.Router
    
    plug PlugJwt
    plug :match
    plug :dispatch
  
    get "/" do
      conn
      |> put_resp_content_type("text/plain")
      |> send_resp(200, "Hello Tester")
    end
  end

  test "Sends 401 when credentials are missing" do
    conn = conn(:get, "/") |> TestRouterPlug.call([])
    assert conn.status == 401
    assert conn.resp_body == "{\"description\":\"Unauthorized\",\"error\":\"Unauthorized\",\"status_code\":401}"
  end

  test "Sends 401 when credentials are missing (settings from config)" do
    conn = conn(:get, "/") |> TestRouterPlugFromConfig.call([])
    assert conn.status == 401
    assert conn.resp_body == "{\"description\":\"Unauthorized\",\"error\":\"Unauthorized\",\"status_code\":401}"
  end

  test "Passes connection and assigns claims when JWT token is valid" do
    payload = %{ sub: 1234567890, name: "John Doe", admin: true }
    {:ok, token} = Joken.Token.encode("secret", TestJsx, payload)

    auth_header = "Bearer " <> token
    conn = conn(:get, "/", []) 
    |> put_req_header("authorization", auth_header)
    |> TestRouterPlug.call([])
    
    assert conn.status == 200
    assert conn.resp_body == "Hello Tester"
    assert conn.assigns.claims == %{admin: true, name: "John Doe", sub: 1234567890}
  end

  test "Passes connection and assigns claims when JWT token is valid (settings from config)" do
    payload = %{ sub: 1234567890, name: "John Doe", admin: true }
    {:ok, token} = Joken.Token.encode("test", TestJsx, payload)

    auth_header = "Bearer " <> token
    conn = conn(:get, "/", []) 
    |> put_req_header("authorization", auth_header)
    |> TestRouterPlugFromConfig.call([])

    assert conn.status == 200
    assert conn.resp_body == "Hello Tester"
    assert conn.assigns.claims == %{admin: true, name: "John Doe", sub: 1234567890}
  end

  test "Send 401 when invalid token sent" do
    incorrect_credentials = "Bearer " <> "Not a token"
    conn = conn(:get, "/", []) 
    |> put_req_header("authorization", incorrect_credentials)
    |> TestRouterPlug.call([])

    assert conn.status == 401
    assert conn.resp_body == "{\"description\":\"Invalid JSON Web Token\",\"error\":\"Unauthorized\",\"status_code\":401}"
  end

  test "Send 401 when invalid token sent (settings from config)" do
    incorrect_credentials = "Bearer " <> "Not a token"
    conn = conn(:get, "/", []) 
    |> put_req_header("authorization", incorrect_credentials)
    |> TestRouterPlugFromConfig.call([])

    assert conn.status == 401
    assert conn.resp_body == "{\"description\":\"Invalid JSON Web Token\",\"error\":\"Unauthorized\",\"status_code\":401}"
  end
end
