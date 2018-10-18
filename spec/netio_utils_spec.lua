package.path = package.path .. ';./?/init.lua'

local utils

describe('lua-netio\'s #helper functions', function()
  setup(function()
    utils = require('netio.utils')
  end)

  teardown(function()
    utils = nil
  end)

  describe('- build urls', function()
    it('- is build correctly without port', function()
      local url = 'http://netio-4.netio-products.com'
      local expected = 'http://netio-4.netio-products.com/netio.cgi'

      assert.are.same(expected, utils.build_url(url, 'url'))
    end)

    it('- is build correctly if URL have ending /', function()
      local url = 'http://netio-4.netio-products.com/'
      local expected = 'http://netio-4.netio-products.com/netio.cgi'

      assert.are.same(expected, utils.build_url(url, 'url'))
    end)

    it('- is build correctly if URL have ending / and port as parameter', function()
      local url = 'http://netio-4.netio-products.com/'
      local port = 8080
      local expected = 'http://netio-4.netio-products.com:8080/netio.cgi'

      assert.are.same(expected, utils.build_url(url, port, 'url'))
    end)

    it('- is build correctly if URL have ending /, port as parameter and json api', function()
      local url = 'http://netio-4.netio-products.com/'
      local port = 8080
      local expected = 'http://netio-4.netio-products.com:8080/netio.json'

      assert.are.same(expected, utils.build_url(url, port, 'json'))
    end)
  end)

  describe('- build Outputs table for JSON API', function()
    it('- input: id(int), action(int)', function()
      local expected = { Outputs = { { ID = 1, Action = 0 } } }

      assert.are.same(expected, utils.build_outputs_tbl(1, 0))
    end)

    it('- input: id(int), action(int), delay in s(int)', function()
      local expected = { Outputs = { { ID = 1, Action = 2, Delay = 5000 } } }

      assert.are.same(expected, utils.build_outputs_tbl(1, 2, 5))
    end)

    it('- input: id(int), action(string), delay in s(int)', function()
      local expected = { Outputs = { { ID = 1, Action = 2, Delay = 5000 } } }

      assert.are.same(expected, utils.build_outputs_tbl(1, 'soff', 5))
    end)

    it('- input: id(tbl), action(int)', function()
      local expected = { Outputs = { { ID = 1, Action = 0 }, { ID = 2, Action = 0 } } }

      assert.are.same(expected, utils.build_outputs_tbl({1, 2}, 0))
    end)

    it('- input: id(tbl), action(string)', function()
      local expected = { Outputs = { { ID = 1, Action = 0 }, { ID = 2, Action = 0 } } }

      assert.are.same(expected, utils.build_outputs_tbl({1, 2}, 'off'))
    end)

    it('- input: id(tbl), action(int), delay in s(int)', function()
      local expected = { Outputs = { { ID = 1, Action = 2, Delay = 5000 }, { ID = 2, Action = 2, Delay = 5000 } } }

      assert.are.same(expected, utils.build_outputs_tbl({1, 2}, 2, 5))
    end)

    it('- input: one table, which contains nested tables which contains id, action, delay', function()
      local expected = { Outputs = { { ID = 1, Action = 0 }, { ID = 2, Action = 2, Delay = 5000 } } }

      assert.are.same(expected, utils.build_outputs_tbl({ { id = 1, action = 0 },
                                                          { id = 2, action = 2, delay = 5 } }))
    end)

    it('- input: one table, which contains nested tables which contains id, action(int & string), delay', function()
      local expected = { Outputs = { { ID = 1, Action = 0 }, { ID = 2, Action = 2, Delay = 5000 } } }

      assert.are.same(expected, utils.build_outputs_tbl({ { id = 1, action = 0 },
                                                          { id = 2, action = 'soff', delay = 5 } }))
    end)
  end)

  describe('- build Outputs table for URL API', function()
    it('- input: id(int), action(int)', function()
      local expected = { ['output1'] = 0 }

      assert.are.same(expected, utils.build_outputs_query(1, 0))
    end)

    it('- input: id(int), action(int), delay in s(int)', function()
      local expected = { ['output1'] = 2, ['delay1'] = 5000 }

      assert.are.same(expected, utils.build_outputs_query(1, 2, 5))
    end)

    it('- input: id(int), action(string), delay in s(int)', function()
      local expected = { ['output1'] = 2, ['delay1'] = 5000 }

      assert.are.same(expected, utils.build_outputs_query(1, 'soff', 5))
    end)

    it('- input: id(tbl), action(int)', function()
      local expected = { ['output1'] = 0, ['output2'] = 0 }

      assert.are.same(expected, utils.build_outputs_query({1, 2}, 0))
    end)

    it('- input: id(tbl), action(string)', function()
      local expected = { ['output1'] = 0, ['output2'] = 0 }

      assert.are.same(expected, utils.build_outputs_query({1, 2}, 'off'))
    end)

    it('- input: id(tbl), action(int), delay in s(int)', function()
      local expected = { ['output1'] = 2, ['delay1'] = 5000, ['output2'] = 2, ['delay2'] = 5000 }

      assert.are.same(expected, utils.build_outputs_query({1, 2}, 2, 5))
    end)

    it('- input: one table, which contains nested tables which contains id, action, delay', function()
      local expected = { ['output1'] = 0, ['output2'] = 2, ['delay2'] = 5000 }

      assert.are.same(expected, utils.build_outputs_query({ { id = 1, action = 0 },
                                                          { id = 2, action = 2, delay = 5 } }))
    end)

    it('- input: one table, which contains nested tables which contains id, action(int & string), delay', function()
      local expected = { ['output1'] = 0, ['output2'] = 2, ['delay2'] = 5000 }

      assert.are.same(expected, utils.build_outputs_query({ { id = 1, action = 0 },
                                                          { id = 2, action = 'soff', delay = 5 } }))
    end)
  end)
end)