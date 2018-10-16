local requests = require('requests')

local utils = {}

-- HTTP error codes and their descriptions like they're described in the
-- API docs
local ERROR_STATES = {
    ['400'] = 'Bad Request (Control command syntax error)',
    ['401'] = 'Unauthorized (Invalid username or password)',
    ['403'] = 'Forbidden (API is not enabled or Read only)',
    ['500'] = 'Internal server error'
}

-- used to translate actions if they are given as string
local ACTIONS = { 
  off = 0, on = 1, soff = 2, son = 3,
  toggle = 4, nochange = 5, ignore = 6
}

-- translates the ids, action and delay to the correct format, which the
-- URL API understands
function utils.build_outputs_query(ids, action, delay)
  local query = {}

  action = tonumber(action) or ACTIONS[action]
  delay = tonumber(delay) and delay * 1000

  if type(ids) ~= 'table' and action then
    query['output' .. ids] = action
    query['delay' .. ids] = delay
  elseif type(ids) == 'table' and action then
    for _, v in ipairs(ids) do
      query['output' .. v] = action
      query['delay' .. v] = delay
    end
  elseif type(ids) == 'table' and not action and not delay then
    for _, v in ipairs(ids) do
      query['output' .. v.id] = tonumber(v.action) or ACTIONS[v.action]
      query['delay' .. v.id] = tonumber(v.delay) and v.delay * 1000
    end
  end

  return query
end

-- translates the ids, action and delay to the correct format, which the
-- JSON API understands
function utils.build_outputs_tbl(ids, action, delay)
  local tbl = { Outputs = {} }

  action = tonumber(action) or ACTIONS[action]
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
          Action = tonumber(v.action) or ACTIONS[v.action],
          Delay = tonumber(v.delay) and v.delay * 1000
        }
    end
  end

  return tbl
end

-- makes the request with lua-requests library and do some error
-- handling
function utils.api_request(self, method, data)
  local ok, resp

  if self.api == 'json' then
    ok, resp = pcall(requests[method], {
        url = self.url,
        auth = self.auth,
        data = data
      })
  else
    ok, resp = pcall(requests[method], {
        url = self.url,
        params = data
      })
  end

  if not ok then
    return nil, "Request failed: " .. tostring(resp)
  end

  local status = tostring(resp.status_code)
  if ERROR_STATES[status] then
    return nil, ERROR_STATES[status]
  end

  if self.api == 'json' then
    local json = resp.json()

    if not json then
      return nil, 'Couldn\'t parse response as JSON'
    end

    return json
  end

  -- if we're here, resp should be 'OK'
  return resp.text == 'OK'
end

-- builds the requests url
-- returns formated like this: scheme://url(:port)/netio.json
function utils.build_url(url, port, api)
  if url:sub(-1) == '/' then
    url = url:sub(1, -2)
  end

  if not api and type(port) ~= 'number' then
    api = port
    port = nil
  end

  if port then
    url = url .. ':' .. port
  end

  if api == 'json' then
    return url .. '/netio.json'
  elseif api == 'url' then
    return url .. '/netio.cgi'
  end
end

return utils