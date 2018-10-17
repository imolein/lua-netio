-- setup path to find the project src files
package.path = './src/?.lua;' .. package.path

local Netio = require('netio.json')
local inspect = require('inspect')
local resp, err

-- Initialize a Netio socket
local netio1 = Netio.new({
    url = 'http://netio-4all.netio-products.com/',
    port = 8080,
    user = 'write',
    pass = 'demo'
  })

print(inspect(netio1))

-- Whats the model name of the Netio we control?
resp, err = netio1:general_info()
print('The Netio Model is ' .. resp.Model)

-- Whats the state of output1?
resp, err = netio1:outputs_info(1)
print('Current state of output1: ' .. resp.State)

local state = resp.State

-- New we toggle output1 and check if the state has changed
resp, err = netio1:outputs_toggle(1)

if resp[1].State and resp[1].State ~= state then
  print('Successfully toggled output1.')
  print('  New state is: ' .. resp[1].State)
elseif not resp[1].State then
  print('Something went wrong: ' .. err)
end