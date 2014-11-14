PlugJwt
=======

A JWT Plug

Usage:

```
    plug PlugJwt, secret: "secret", claims: %{aud: "spiderman"}
```

Parameters:

* secret: The secret used to encode and verify the token

* claims (optional):  A map containing aud, iss, and sub values to verify if needed. Default: %{}
