PlugJwt
=======

A JWT Plug

Usage:

```elixir
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
