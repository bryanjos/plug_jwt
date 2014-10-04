PlugJwt
=======

A JWT Plug

Usage:

```
    plug PlugJwt, secret: "secret", verify: &verify_function/1, claims: %{aud: "spiderman"}
```

Parameters:

* secret: The secret used to encode and verify the token

* verify: A function that takes the payload and verifies it's ok (i.e. make sure username is valid, etc)

* claims (optional):  A map containing aud, iss, and sub values to verify if needed. Default: %{}
