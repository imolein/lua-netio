--- Implements the JSON API: [Protocol version: JSON API Version 2.0](https://www.netio-products.com/files/download/sw/version/JSON---description-of-NETIO-M2M-API-interface_1-2-0.pdf)(PDF)
--
-- @module netio.json

package.path = package.path .. ';./src/?/init.lua;./src/?.lua'

local Wcore = require('netio.web_core')
local utils = require('netio.utils')
local basic_auth = require('requests').HTTPBasicAuth

local jsonapi = {}

-- NetioJSON class
local JSONapi = {}

setmetatable(JSONapi, { __index = Wcore })

--- Get all status informations from the device
--
-- @function instance:info
-- @treturn ?table|nil [Status table](../manual/dstructures.md.html#Status_table)
-- @treturn ?nil|string error message
-- @usage local info = netio1:info()
function JSONapi:info()
  return utils.api_request(self, 'get')
end

--- Get device informations
-- like serial number, firmware version etc.
-- @function instance:general_info
-- @treturn ?table|nil [Agent table](../manual/dstructures.md.html#Agent_table)
-- @treturn ?nil|string error message
-- @usage local info = netio1:general_info()
function JSONapi:general_info()
  return self:info()['Agent']
end

--- Get output informations
-- about a specific or all outputs
-- @function instance:outputs_info
-- @int[opt] id Output ID
-- @treturn ?table|nil [Outputs table](../manual/dstructures.md.html#Ouputs_table)
-- @treturn ?nil|string error message
-- @usage local outputs = netio1:output_info()
--local output1 = netio1:output_info(2)
function JSONapi:outputs_info(id)
  if id then
    return self:info()['Outputs'][id]
  else
    return self:info()['Outputs']
  end
end

--- Get global metering informations
-- like voltage, frequency et cetera
-- @function instance:measure_info
-- @treturn ?table|nil [GlobalMeasure table](../manual/dstructures.md.html#GlobalMeasure_table)
-- @treturn ?nil|string error message
-- @usage local info = netio1:measure_info()
function JSONapi:measure_info()
  local info = self:info()

  if not info.GlobalMeasure then
    return nil, 'Metering are only available on NETIO Model "NETIO 4All".' ..
                ' Your model is: ' .. info.Agent.Model
  end

  return info.GlobalMeasure
end

--- Creates new instance.
-- After instantiated, also all methods from [web_core](web_core.html) are available.
-- @function new
-- @tab opts options table with arguments
-- @string opts.url URL or IP of the netio you want to speak with
-- @int[opt] opts.port Additional port (can also be written directly into the URL)
-- @string[opt] opts.user Name of the user, who has the right to read and/or write to the API
-- @string[opt] opts.pass The password of the user
-- @treturn object Instance table
-- @usage local Netio = require('netio.json')
-- local netio_socket = Netio.new({
--     url = 'http://netio.de',
--     user = 'demo',
--     pass = 'demo'
--   })
function jsonapi.new(opts)
  assert(opts.url, 'URL required!')
  
  local api = 'json'
  
  local auth
  if opts.user and opts.pass then
    auth = basic_auth(opts.user, opts.pass)
  end

  local self = {
    url = utils.build_url(opts.url, opts.port, api),
    auth = auth,
    api = api
  }

  return setmetatable(self, { __index = JSONapi })
end

return jsonapi