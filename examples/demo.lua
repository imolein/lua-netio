-- setup path to find the project src files
package.path = './src/?.lua;./src/?/init.lua;' .. package.path

local Netio = require('netio')

-- Initialize two sockets, one using the URL API and one the JSON API

local socket1 = Netio.new({
    url = 'http://netio-4all.netio-products.com/',
    port = 8080
  })
local socket2 = Netio.new({
    url = 'http://netio-4all.netio-products.com/',
    port = 8080,
    user = 'write',
    pass = 'demo',
    api = 'json'
  })

-- We toggle output 1 of socket1
local ok, err = socket1:outputs_toggle(1)

if ok then
  print('Toggled output 1 of socket1 via URL API')
else
  print(err)
end

-- We can get info from the socket, using the JSON API
local s2model = assert(socket2:general_info()['Model'])

print('Model name of socket2 is ' .. s2model)
