-- setup path to find the project src files
package.path = './src/?.lua;./src/?/init.lua;' .. package.path

local Netio = require('netio.url')

-- Initialize a Netio socket
local netio1 = Netio.new({
    url = 'http://netio-4all.netio-products.com/',
    port = 8080
  })

-- We toggle output 1 of the socket
local ok, err = netio1:outputs_toggle(1)

if ok then
  print('Toggled output 1 of via URL API')
else
  print(err)
end