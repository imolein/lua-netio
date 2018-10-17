--- Implements the URL API: [Protocol version: URL API Version 1.0](https://www.netio-products.com/files/download/sw/version/URL-API---description-of-NETIO-M2M-API-interface---PDF_1-1-0.pdf)(PDF)
--
-- The **URL API** is write-only (see specification), so you can't read informations about the outputs etc with it.
--
-- @module netio.url

package.path = package.path .. ';./src/?/init.lua;./src/?.lua'

local Wcore = require('netio.web_core')
local utils = require('netio.utils')

local urlapi = {}

--- Creates new instance.
-- Please look into [web_core](web_core.html) for the method documentation you can use with this module.
-- @function new
-- @tab opts options table with arguments
-- @string opts.url URL or IP of the netio you want to speak with
-- @int[opt] opts.port Additional port (can also be written directly into the URL)
-- @string[opt] opts.pass The password of the user
-- @treturn object Instance table
-- @usage local Netio = require('netio.url')
-- local netio_socket = Netio.new({
--     url = 'http://netio.de',
--     pass = 'demo'
--   })
function urlapi.new(opts)
  assert(opts.url, 'URL required!')
  
  local api = 'url'
  
  local self = {
    url = utils.build_url(opts.url, opts.port, api),
    pass = opts.pass,
    api = api
  }
  
  return setmetatable(self, { __index = Wcore })
end

return urlapi