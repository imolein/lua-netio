--- Implements two of three available Web API's:
--
-- * [Protocol version: JSON API Version 2.0](https://www.netio-products.com/files/download/sw/version/JSON---description-of-NETIO-M2M-API-interface_1-2-0.pdf)(PDF)
-- * [Protocol version: URL API Version 1.0](https://www.netio-products.com/files/download/sw/version/URL-API---description-of-NETIO-M2M-API-interface---PDF_1-1-0.pdf)(PDF)
--
--    local Netio = require('netio')
--    local netio1 = Netio.new({
--        url = 'http://netio-4all.netio-products.com',
--        port = 8080,
--        user = 'write',
--        pass = 'demo',
--        api = 'json'
--      })
--    local output1 = netio1:outputs_info(1)
--    for k, v in pairs(output1) do
--      print(k, v)
--    end
--
-- The **URL API** is write-only, so you can't read informations about the outputs etc with it. You have to use the **JSON API** for that.
--
-- @module netio

local utils = require('netio.utils')
local basic_auth = require('requests').HTTPBasicAuth

local netio = {
  _VERSION      = '0.1-0',
  _DESCRIPTION  = 'lua-netio is a library to control outputs of NETIO 4x smart power sockets from NETIO products a.s..',
  _URL          = 'https://git.kokolor.es/imo/lua-netio',
  _LICENCE      = [[
  MIT Licence

  Copyright (c) 2018 Sebastian Huebner

  Permission is hereby granted, free of charge, to any person obtaining a
  copy of this software and associated documentation files (the "Software"),
  to deal in the Software without restriction, including without limitation
  the rights to use, copy, modify, merge, publish, distribute, sublicense,
  and/or sell copies of the Software, and to permit persons to whom the Software
  is furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
  IN THE SOFTWARE.
  ]]
}

-- Netio class
local Netio = {}

--- Perform actions on output's (**JSON**, **URL**)
--
-- @function instance:outputs_action
-- @tparam ?int|table ids The output ID where you want to perform the action. If you want to perform the same action on multiple outputs, the ID's have to be in a table
-- @tparam ?int|string action The action you want to perform (**0** or **'off'**, **1** or **'on'**, **2** or **'soff'**, **3** or **'son'**, **4** or **'toggle'**, **5** or **'nochange'**, **6** or **'ignore'**)
-- @int[opt=5] delay Define delay for **shorton** and **shortoff** in seconds
-- @treturn ?table|boolean|nil [Outputs table](../manual/dstructures.md.html#Ouputs_table) (**JSON**) or **true** (**URL**)
-- @treturn ?nil|string error message
-- @usage -- possible usecases
-- local resp = output_action(1, 2, 2) -- Switch off output 1 for 2 seconds
-- local resp = output_action({1, 2}, 2, 2) -- Switch off output 1 and 2 for 2 seconds
-- local resp = output_action({ {id=1, action=2, delay=2}, {id=2, action=2}, {id=3, action=4} }) -- Switch off ouput 1 for 2 seconds and output 2 for 5 (default if no value is given) and toggle output 3
function Netio:outputs_action(ids, action, delay)
  local outputs, method

  if self.api == 'json' then
    outputs = utils.build_outputs_tbl(ids, action, delay)
    method = 'post'
  elseif self.api == 'url' then
    outputs = utils.build_outputs_query(ids, action, delay)
    outputs.pass = self.pass
    method = 'get'
  end

  local resp = utils.api_request(self, method, outputs)

  if type(resp) == 'table' and resp['Outputs'] then
    return resp['Outputs']
  end

  return resp
end

--- Switch outputs off (**JSON**, **URL**)
--
-- @function instance:outputs_off
-- @tparam ?int|table ids Output ID/ID's
-- @treturn ?table|boolean|nil [Outputs table](../manual/dstructures.md.html#Ouputs_table) (**JSON**) or **true** (**URL**)
-- @treturn ?nil|string error message
-- @usage local resp = netio1:output_off(1)
function Netio:outputs_off(ids)
  return self:outputs_action(ids, 0)
end

--- Switch outputs on (**JSON**, **URL**)
--
-- @function instance:outputs_on
-- @tparam ?int|table ids Output ID/ID's
-- @treturn ?table|boolean|nil [Outputs table](../manual/dstructures.md.html#Ouputs_table) (**JSON**) or **true** (**URL**)
-- @treturn ?nil|string error message
-- @usage local resp = netio1:output_on(1)
function Netio:outputs_on(ids)
  return self:outputs_action(ids, 1)
end

--- Switch outputs off for a specific timeframe (**JSON**, **URL**)
--
-- @function instance:outputs_shortoff
-- @tparam ?int|table ids Output ID/ID's
-- @int delay Delay between off and on in seconds
-- @treturn ?table|boolean|nil [Outputs table](../manual/dstructures.md.html#Ouputs_table) (**JSON**) or **true** (**URL**)
-- @treturn ?nil|string error message
-- @usage local resp = netio1:output_shortoff(1)
function Netio:outputs_shortoff(ids, delay)
  return self:outputs_action(ids, 2, delay)
end

--- Switch outputs on for a specific timeframe (**JSON**, **URL**)
--
-- @function instance:outputs_shorton
-- @tparam ?int|table ids Output ID/ID's
-- @int delay Delay between on and off in seconds
-- @treturn ?table|boolean|nil [Outputs table](../manual/dstructures.md.html#Ouputs_table) (**JSON**) or **true** (**URL**)
-- @treturn ?nil|string error message
-- @usage local resp = netio1:output_shorton(1)
function Netio:outputs_shorton(ids, delay)
  return self:outputs_action(ids, 3, delay)
end

--- Invert the outputs state (**JSON**, **URL**)
--
-- @function instance:outputs_toggle
-- @tparam ?int|table ids Output ID/ID's
-- @treturn ?table|boolean|nil [Outputs table](../manual/dstructures.md.html#Ouputs_table) (**JSON**) or **true** (**URL**)
-- @treturn ?nil|string error message
-- @usage local resp = netio1:output_toggle(1)
function Netio:outputs_toggle(ids)
  return self:outputs_action(ids, 4)
end

-- NetioJSON class
local NetioJSON = {}

--- Get all status informations from the device (**JSON**)
--
-- @function instance:info
-- @treturn ?table|nil [Status table](../manual/dstructures.md.html#Status_table)
-- @treturn ?nil|string error message
-- @usage local info = netio1:info()
function NetioJSON:info()
  return utils.api_request(self, 'get')
end

--- Get device informations
-- like serial number, firmware version etc. (**JSON**)
-- @function instance:general_info
-- @treturn ?table|nil [Agent table](../manual/dstructures.md.html#Agent_table)
-- @treturn ?nil|string error message
-- @usage local info = netio1:general_info()
function NetioJSON:general_info()
  return self:info()['Agent']
end

--- Get output informations
-- about a specific or all outputs (**JSON**)
-- @function instance:outputs_info
-- @int[opt] id Output ID
-- @treturn ?table|nil [Outputs table](../manual/dstructures.md.html#Ouputs_table)
-- @treturn ?nil|string error message
-- @usage local outputs = netio1:output_info()
--local output1 = netio1:output_info(2)
function NetioJSON:outputs_info(id)
  if id then
    return self:info()['Outputs'][id]
  else
    return self:info()['Outputs']
  end
end

--- Get global metering informations
-- like voltage, frequency et cetera (**JSON**)
-- @function instance:measure_info
-- @treturn ?table|nil [GlobalMeasure table](../manual/dstructures.md.html#GlobalMeasure_table)
-- @treturn ?nil|string error message
-- @usage local info = netio1:measure_info()
function NetioJSON:measure_info()
  local info = self:info()

  if not info.GlobalMeasure then
    return nil, 'Metering are only available on NETIO Model "NETIO 4All".' ..
                ' Your model is: ' .. info.Agent.Model
  end

  return info.GlobalMeasure
end

-- Public functions

--- Create new instance
-- @function new
-- @tab opts options table with arguments
-- @string opts.url URL of the netio you want to speak with
-- @int[opt] opts.port Additional port (can also be written directly into the URL)
-- @string[opt] opts.user Name of the user, who has the right to read and/or write to the API
-- @string[opt] opts.pass The password of the user
-- @string[opt='url'] opts.api specify which API should be used (**json** or **url**)
-- @treturn object Instance table
-- @usage local Netio = require('netio')
-- local socket_url_api = Netio.new({
--     url = 'http://netio.de',
--     pass = 'demo'
--   })
-- local socket_json_api = Netio.new({
--     url = 'http://netio.de',
--     user = 'demo',
--     pass = 'demo',
--     api = 'json'
--   })
function netio.new(opts)
  if not opts.url then return nil, 'URL required!' end

  opts.api = opts.api or 'url'

  local auth
  if opts.user and opts.pass then
    auth = basic_auth(opts.user, opts.pass)
  end

  local self = {
    url = utils.build_url(opts.url, opts.port, opts.api),
    auth = auth,
    pass = opts.pass,
    api = opts.api
  }

  if opts.api == 'url' then
    if self.auth then self.auth = nil end
    return setmetatable(self, { __index = Netio })
  elseif opts.api == 'json' then
    return setmetatable(self, {
        __index = setmetatable(NetioJSON, {
            __index = Netio
          })
        })
  else
    return
  end
end

return netio
