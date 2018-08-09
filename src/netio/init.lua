local requests = require('requests')
--local https = require('ssl.https')
--local json = require('JSON')
--local xml = require('xml2lua')

local function _build_url(opts)
--  local scheme = (opts.https == nil or opts.https == true) and 'https://' or 'http://'
--  local port = opts.port or (scheme == 'https://' and 443) or (scheme == 'http://' and 80)

--  return string.format('%s%s:%d/netio.json', scheme, opts.url:gsub('https?://', ''), port)
  local url
  if not opts.port and opts.url:match('https?://') then
    url = opts.url .. '/netio.json'
    elseif opts.port
end

-- Netio class
local Netio = {}
Netio.__index = Netio

function Netio:new(opts)
  if not opts.url then error('Host required!') end

  if opts.user and opts.passwd then
    auth = requests.HTTPBasicAuth(opts.user, opts.passwd)
  end

  o = {
    url = _build_url(opts),
    auth = auth,
  }

  return setmetatable(o, self)
end

function Netio:info()
  return requests.get({ self.url, auth = self.auth })
end

return Netio