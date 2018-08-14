package.path = package.path .. ';./?/init.lua'

local netio

describe('lua-netio\'s #privat functions', function()
  setup(function()
    _G._TEST = true
    netio = require('netio.json')
  end)

  teardown(function()
    _G._TEST = nil
  end)
  describe('- build urls', function()
    it('- is build correctly without port', function()
      local url = 'http://netio-4.netio-products.com'
      local expected = 'http://netio-4.netio-products.com/netio.json'

      assert.are.same(expected, netio._build_url(url))
    end)

    it('- is build correctly if URL have ending /', function()
      local url = 'http://netio-4.netio-products.com/'
      local expected = 'http://netio-4.netio-products.com/netio.json'

      assert.are.same(expected, netio._build_url(url))
    end)

    it('- is build correctly if URL have ending / and port as parameter', function()
      local url = 'http://netio-4.netio-products.com/'
      local port = 8080
      local expected = 'http://netio-4.netio-products.com:8080/netio.json'

      assert.are.same(expected, netio._build_url(url, port))
    end)
  end)

  describe('- build Outputs table', function()
    it('- input: id(int), action(int)', function()    
      local expected = { { ID = 1, Action = 0 } }
      
      assert.are.same(expected, netio._build_outputs_tbl(1, 0))
    end)
  
    it('- input: id(int), action(int), delay in s(int)', function()    
      local expected = { { ID = 1, Action = 2, Delay = 5000 } }
      
      assert.are.same(expected, netio._build_outputs_tbl(1, 2, 5))
    end)
  
    it('- input: id(tbl), action(int)', function()    
      local expected = { { ID = 1, Action = 0 }, { ID = 2, Action = 0 } }
      
      assert.are.same(expected, netio._build_outputs_tbl({1, 2}, 0))
    end)

    it('- input: id(tbl), action(int), delay in s(int)', function()    
      local expected = { { ID = 1, Action = 2, Delay = 5000 }, { ID = 2, Action = 2, Delay = 5000 } }
      
      assert.are.same(expected, netio._build_outputs_tbl({1, 2}, 2, 5))
    end)

    it('- input: one table, which contains nested tables which contains id, action, delay', function()    
      local expected = { { ID = 1, Action = 0 }, { ID = 2, Action = 2, Delay = 5000 } }

      assert.are.same(expected, netio._build_outputs_tbl({ { id = 1, action = 0 },
                                                          { id = 2, action = 2, delay = 5 } }))
    end)
  end)
end)