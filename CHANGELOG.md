#v0.6.0

* Enhancements
  * Updated to Joken 0.11
  * Will now read from joken config block if there. If not will still used paramters set on plug. Parameters set on the plug will override any parameters in the joken configuration.

* Breaking
  * `secret` is now `secret_key`