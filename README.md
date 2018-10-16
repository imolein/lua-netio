# lua-netio

## Description

lua-netio is a library to control outputs of NETIO 4x smart power sockets from [NETIO products a.s.](https://www.netio-products.com). These Ethernet- or WiFi-connected power sockets can be accessed using a varity of protocols and M2M-API methods, including HTTP(s) CGI, Telnet, XML, JSON and many more.

**Currently implemented:**
* URL API ([Offical doc](https://www.netio-products.com/files/download/sw/version/URL-API---description-of-NETIO-M2M-API-interface---PDF_1-1-0.pdf))
* JSON API ([Offical doc](https://www.netio-products.com/files/download/sw/version/JSON---description-of-NETIO-M2M-API-interface_1-2-0.pdf))

## TODO

* implement Telnet ([Offical doc](https://www.netio-products.com/files/download/sw/version/TELNET---description-of-NETIO-M2M-API-interface_1-0-0.pdf))
* implement Telnet support for NETIO 230B (older model) ([Offical doc](http://www.koukaam.se/koukaam/downloads/MAN_EN_CGI_NETIO_4.x.pdf))
* add rockspec

I'm not planing to implement the XML API, because in my opinion the JSON API is enough, but if someone want to contribute, do it :)

## Example Usage

```lua
local Netio = require('netio')
local netio1 = Netio.new({
    url = 'http://netio-4.netio-products.com',
    port = 8080,
    user = 'write',
    pass= 'demo',
    api = 'json'
  })

local resp, err = netio1:outputs_info(1)
print('Current state of Output1 is ' .. resp.State)
resp, err = netio1:outputs_toggle(1)
print('State after toggle of Output1 is ' .. resp.State)
```

## Documentation

Documentation was generated with [LDoc](https://github.com/stevedonovan/LDoc) and can be read here: https://imolein.github.io/lua-netio/

## Dependencies

* [lua-requests](https://github.com/JakobGreen/lua-requests)

## Tests

You need [busted](https://github.com/Olivine-Labs/busted) to run the tests.

```bash
busted spec/
```

Some tests might fail sporadically. That's because the demo instaces sporadically rejects the commands silently and just return the status JSON object. If you take a look into the NETIO's logfile, you see that the command is rejected, but not why.
