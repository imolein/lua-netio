--- lua-netio is a library to control outputs of NETIO 4x smart power sockets from NETIO products a.s.
--
-- @module netio

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

--- Create new instance.
-- It invokes the new() function of the submodule, specified via **opts.api**
-- @tab opts options table with arguments
-- @string opts.url URL or IP of the Netio socket you want to speak with
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
  opts.api = opts.api or 'url'

  return require('netio.' .. opts.api).new(opts)
end


return netio
