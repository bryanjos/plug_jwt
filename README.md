PlugJwt
=======

A JWT Plug

Usage:

```elixir
    #When reading from joken config block
    plug PlugJwt
    
    #or the module that implements `Joken.Config` can be set explicitly
    plug PlugJwt, config_module: My.Joken.Config

    #You may also add a list of expected claims to verify
    plug PlugJwt, config_module: My.Joken.Config, claims: [aud: "spiderman", admin: true]
```

Parameters:

PlugJWT will attempt to read from your joken config block. Parameters can also be placed on the Plug itself
which overrides the joken configuration

* config_module: The module that implements Joken.Config
