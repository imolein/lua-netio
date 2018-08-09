-- setup path to find the project src files
package.path = './src/?.lua;./src/?/init.lua;' .. package.path

local inspect = require('inspect')
local netio = require('netio')

local n1 = netio:new({
    url = 'http://netio-4.netio-products.com',
  })

print(inspect(n1))