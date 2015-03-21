PlugJwt
=======

A JWT Plug

Usage:

```
    plug PlugJwt, secret: "secret", claims: %{aud: "spiderman"}, json_module: TestJsx
```

Parameters:

* secret: The secret used to encode and verify the token
* json_module: The module that implements `Joken.Codec`
* claims (optional):  A map containing aud, iss, and sub values to verify if needed. Default: %{}
