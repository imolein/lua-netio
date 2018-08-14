local netio = {}
local inspect = require('inspect')
local requests = require('requests')
--local https = require('ssl.https')
--local json = require('JSON')
--local xml = require('xml2lua')


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
  local outputs = {}

  if type(ids) == 'table' and action then
    for k, v in ipairs(ids) do
      outputs[k] = { ID = v, Action = action, Delay = delay and delay * 1000 }
    end
  elseif type(ids) == 'table' and not action and not delay then
    for k, v in ipairs(ids) do
      outputs[k] = { ID = v.id, Action = v.action, Delay = v.delay and v.delay * 1000 }
    end
  else
    outputs[1] = { ID = ids, Action = action, Delay = delay and delay * 1000 }
  end

  return outputs  
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

local Netio = {}

function Netio:info()
  return _api_request(self, 'GET')
end

function Netio:general_info()
  return self:info()['Agent']
end

function Netio:output_info(id)
  if id then
    return self:info()['Outputs'][id]
  else
    return self:info()['Outputs']
  end
end

function Netio:measure_info()
  local info = self:info()

  if not info.GlobalMeasure then
    return nil, 'Metering are only available on NETIO Model "NETIO 4All".' ..
                ' Your model is: ' .. info.Agent.Model
  end
  
  return info.GlobalMeasure
end

function Netio:output_action(ids, action, delay)
  local actions = { off = 0, on = 1, soff = 2, son = 3,
                    toggle = 4, no_change = 5, ignore = 6 }
  local outputs

  if action and type(action) == string then
    outputs = _build_outputs_tbl(ids, actions[action], delay)
  else
    outputs = _build_outputs_tbl(ids, tonumber(action), delay)
  end
  --print(inspect(outputs))
  return _api_request(self, 'POST', { Outputs = outputs })
end

function Netio:output_off(ids)
  return self:output_action(ids, 0)
end

function Netio:output_on(ids)
  return self:output_action(ids, 1)
end

function Netio:output_shortoff(ids, delay)
  return self:output_action(ids, 2, delay)
end

function Netio:output_shorton(ids, delay)
  return self:output_action(ids, 3, delay)
end

function Netio:output_toggle(ids)
  return self:output_action(ids, 4)
end

function Netio:output_nochange(ids)
  return self:output_action(ids, 5)
end

-- privat methods

function netio.new(opts)
  if not opts.url then return nil, 'URL required!' end

  local auth
  if opts.user and opts.passwd then
    auth = requests.HTTPBasicAuth(opts.user, opts.passwd)
  end

  local o = {
    url = _build_url(opts.url, opts.port),
    auth = auth,
  }

  return setmetatable(o, { __index = Netio })
end

-- For tests

if _TEST then
  netio._build_url = _build_url
  netio._build_outputs_tbl = _build_outputs_tbl
end

return netio