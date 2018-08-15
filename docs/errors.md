# Errors

The following errors are returned as second argument if something went wrong:

```lua
'Control command syntax error' -- http status 400
'Invalid username or password' -- http status 401
'Read only' -- http status 403
'Internal server error' -- http status 500
'Metering are only available on NETIO Model "NETIO 4All". Your model is: $modulename' -- if measure_info() function is used on model other then NETIO 4All
```
