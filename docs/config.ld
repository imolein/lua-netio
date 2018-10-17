project = 'lua-netio-api'
title = 'lua-netio-api documentation'
description = 'Lua module to control NETIO smart sockets over their M2M API\'s'
use_markdown_titles = true
dir = '../docs'
file = { 
  '../src/netio.lua',
  '../src/netio/json.lua',
  '../src/netio/url.lua',
  '../src/netio/web_core.lua'
}
format = 'discount'
sort_modules = true
topics = { 'dstructures.md', 'errors.md' }
kind_names = { topic = 'Manual', script = 'Programs' }
examples = {
  '../examples/jsonapi-demo.lua',
  '../examples/urlapi-demo.lua'
}
