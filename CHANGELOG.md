#v0.7.1
  * Enchancements
    * Updated to Joken 0.15.0
    * Update to Plug 1.0

#v0.7.0
  * Enchancements
    * Updated to Joken 0.14.0

  * Breaking
    * The only config option is `config_module` which takes a module that implements `Joken.Config`


#v0.6.0

* Enhancements
  * Updated to Joken 0.11
  * Will now read from joken config block if there. If not will still used paramters set on plug. Parameters set on the plug will override any parameters in the joken configuration.

* Breaking
  * `secret` is now `secret_key`