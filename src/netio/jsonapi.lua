--- JSON API module
-- - Implements [Protocol version: JSON Version 2.0](https://www.netio-products.com/files/download/sw/version/JSON---description-of-NETIO-M2M-API-interface_1-2-0.pdf)(PDF)
--
--    local Netio = require('netio.jsonapi')
--    local netio1 = Netio.new({
--        url = 'http://netio-4all.netio-products.com',
--        port = 8080,
--        user = 'write',
--        pass = 'demo'
--      })
--    local output1 = netio1:outputs_info(1)
--    for k, v in pairs(output1) do
--      print(k, v)
--    end
--
-- @module netio.jsonapi

local json_api = {}

local requests = require('requests')


-- private functions

-- builds the requests url
-- returns formated like this: scheme://url(:port)/netio.json
local function _build_url(url, port)
  if url:sub(-1) == '/' then
    url = url:sub(1, -2)
  end

  if port then
    url = url .. ':' .. port
  end

  return url .. '/netio.json'
end

-- returns a table with the correct format to work
-- with the NETIO API
local function _build_outputs_tbl(ids, action, delay)
  local actions = { off = 0, on = 1, soff = 2, son = 3,
                  toggle = 4, nochange = 5, ignore = 6 }
  local tbl = { Outputs = {} }

  action = tonumber(action) or actions[action]
  delay = tonumber(delay) and delay * 1000

  if type(ids) ~= 'table' and action then
    tbl.Outputs[1] = {
        ID = tonumber(ids),
        Action = action,
        Delay = delay
      }
  elseif type(ids) == 'table' and action then
    for k, v in ipairs(ids) do
      tbl.Outputs[k] = {
          ID = tonumber(v),
          Action = action,
          Delay = delay
        }
    end
  elseif type(ids) == 'table' and not action and not delay then
    for k, v in ipairs(ids) do
      tbl.Outputs[k] = {
          ID = v.id,
          Action = tonumber(v.action) or actions[v.action],
          Delay = tonumber(v.delay) and v.delay * 1000
        }
    end
  end

  return tbl
end

-- makes the request with lua-requests library and do some error
-- handling
local function _api_request(self, method, data)
  local resp, err
  local ok, resp_obj = pcall(requests[method:lower()], {
                                                        url = self.url,
                                                        auth = self.auth,
                                                        data = data
                                                        })

  if not ok then
    return nil, "Request failed: " .. tostring(resp_obj)
  end

  local status = resp_obj.status_code
  if status == 400 then
    return nil, 'Control command syntax error'
  elseif status == 401 then
    return nil, 'Invalid username or password'
  elseif status == 403 then
    return nil, 'Read only'
  elseif status == 500 then
    return nil, 'Internal server error'
  end

  resp, err = resp_obj.json()
  if not resp then
    return nil, 'Couldn\'t parse response as JSON'
  end

  return resp
end


-- privat methods


local NetioJson = {}

--- Get all status informations from the device (method)
--
-- @function instance:info
-- @treturn ?table|nil [Status table](../manual/dstructures.md.html#Status_table)
-- @treturn ?nil|string error message
-- @usage local info = netio1:info()
function NetioJson:info()
  return _api_request(self, 'GET')
end

--- Get device informations
-- like serial number, firmware version etc. (method)
-- @function instance:general_info
-- @treturn ?table|nil [Agent table](../manual/dstructures.md.html#Agent_table)
-- @treturn ?nil|string error message
-- @usage local info = netio1:general_info()
function NetioJson:general_info()
  return self:info()['Agent']
end

--- Get output informations
-- about a specific or all outputs (method)
-- @function instance:outputs_info
-- @int id Output ID
-- @treturn ?table|nil [Outputs table](../manual/dstructures.md.html#Ouputs_table)
-- @treturn ?nil|string error message
-- @usage local outputs = netio1:output_info()
--local output1 = netio1:output_info(2)
function NetioJson:outputs_info(id)
  if id then
    return self:info()['Outputs'][id]
  else
    return self:info()['Outputs']
  end
end

--- Get global metering informations
-- like voltage, frequency et cetera (method)
-- @function instance:measure_info
-- @treturn ?table|nil [GlobalMeasure table](../manual/dstructures.md.html#GlobalMeasure_table)
-- @treturn ?nil|string error message
-- @usage local info = netio1:measure_info()
function NetioJson:measure_info()
  local info = self:info()

  if not info.GlobalMeasure then
    return nil, 'Metering are only available on NETIO Model "NETIO 4All".' ..
                ' Your model is: ' .. info.Agent.Model
  end

  return info.GlobalMeasure
end

--- Perform actions on output's (method)
--
-- @function instance:outputs_action
-- @tparam ?int|table ids The output ID where you want to perform the action. If you want to perform the same action on multiple outputs, the ID's have to be in a table and i
-- @tparam ?int|string action The action you want to perform (0 or off, 1 or on, 2 or soff, 3 or son, 4 or toggle, 5 or nochange, 6 or ignore)
-- @int[opt=5000] delay Define delay for shorton and shortoff in seconds
-- @treturn ?table|nil [Outputs table](../manual/dstructures.md.html#Ouputs_table)
-- @treturn ?nil|string error message
-- @usage -- possible usecases
-- local resp = output_action(1, 2, 2) -- Switch off output 1 for 2 seconds
-- local resp = output_action({1, 2}, 2, 2) -- Switch off output 1 and 2 for 2 seconds
-- local resp = output_action({ {id=1, action=2, delay=2}, {id=2, action=2}, {id=3, action=4} }) -- Switch off ouput 1 for 2 seconds and output 2 for 5 (default if no value is given) and toggle output 3
function NetioJson:outputs_action(ids, action, delay)
  local outputs = _build_outputs_tbl(ids, action, delay)

  return _api_request(self, 'POST', outputs)['Outputs']
end

--- Switch outputs off (method)
--
-- @function instance:outputs_off
-- @tparam ?int|table ids Output ID/ID's
-- @treturn ?table|nil [Outputs table](../manual/dstructures.md.html#Ouputs_table)
-- @treturn ?nil|string error message
-- @usage local info = netio1:output_off(1)
function NetioJson:outputs_off(ids)
  return self:output_action(ids, 0)
end

--- Switch outputs on (method)
--
-- @function instance:outputs_on
-- @tparam ?int|table ids Output ID/ID's
-- @treturn ?table|nil [Outputs table](../manual/dstructures.md.html#Ouputs_table)
-- @treturn ?nil|string error message
-- @usage local info = netio1:output_on(1)
function NetioJson:outputs_on(ids)
  return self:output_action(ids, 1)
end

--- Switch outputs off for a specific timeframe (method)
--
-- @function instance:outputs_shortoff
-- @tparam ?int|table ids Output ID/ID's
-- @int delay Delay between off and on in seconds
-- @treturn ?table|nil [Outputs table](../manual/dstructures.md.html#Ouputs_table)
-- @treturn ?nil|string error message
-- @usage local info = netio1:output_shortoff(1)
function NetioJson:outputs_shortoff(ids, delay)
  return self:output_action(ids, 2, delay)
end

--- Switch outputs on for a specific timeframe (method)
--
-- @function instance:outputs_shorton
-- @tparam ?int|table ids Output ID/ID's
-- @int delay Delay between on and off in seconds
-- @treturn ?table|nil [Outputs table](../manual/dstructures.md.html#Ouputs_table)
-- @treturn ?nil|string error message
-- @usage local info = netio1:output_shorton(1)
function NetioJson:outputs_shorton(ids, delay)
  return self:output_action(ids, 3, delay)
end

--- Invert the outputs state (method)
--
-- @function instance:outputs_toggle
-- @tparam ?int|table ids Output ID/ID's
-- @treturn ?table|nil [Outputs table](../manual/dstructures.md.html#Ouputs_table)
-- @treturn ?nil|string error message
-- @usage local info = netio1:output_toggle(1)
function NetioJson:outputs_toggle(ids)
  return self:output_action(ids, 4)
end

-- Public functions

--- Create new instance
-- @function new
-- @tab opts options table with arguments
-- @string opts.url URL of the netio you want to speak with
-- @int[opt] opts.port Additional port (can also be written directly into the URL)
-- @string[opt] opts.user Name of the user, who has the right to read and/or write to the API
-- @string[opt] opts.pass The password of the user
-- @treturn object Instance table
-- @usage local Netio = require('netio.json')
-- local netio1 = Netio.new({
--     url = 'http://netio.de',
--     user = 'demo',
--     pass = 'demo'
--   })
function json_api.new(opts)
  if not opts.url then return nil, 'URL required!' end

  local auth
  if opts.user and opts.pass then
    auth = requests.HTTPBasicAuth(opts.user, opts.pass)
  end

  local self = {
    url = _build_url(opts.url, opts.port),
    auth = auth,
  }

  return setmetatable(self, { __index = NetioJson })
end

-- For tests

if _TEST then
  json_api._build_url = _build_url
  json_api._build_outputs_tbl = _build_outputs_tbl
end

return json_api
