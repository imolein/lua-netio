package.path = package.path .. ';./?.lua'

local Netio, n1, sleep

describe('lua-netio module', function()
  setup(function()
    Netio = require('netio')
    sleep = function(n)
        os.execute("sleep " .. tonumber(n))
      end
  end)

  teardown(function()
    Netio = nil
  end)

  describe('- #JSON API', function()
    setup(function()
      -- Some test might fail, because the NETIO 4ALL sporadically rejects
      -- some requests. This rejects are not detectable because the NETIO
      -- respond with valid static information but no error at all.
      -- You can see it rejected, only by looking in the NETIO's log file.
      n1 = Netio.new({
        --url = 'http://netio-4all.netio-products.com',
        url = 'http://netio-4.netio-products.com',
        port = 8080,
        user = 'write',
        pass = 'demo',
        api = 'json'
      })
    end)

    after_each(function()
      local resp = n1:outputs_on({ 1, 2, 3, 4 })
    end)

    teardown(function()
      n1 = nil
    end)

    it('- info API call', function()
      local response = n1:info()

      assert.is.not_nil(response.Agent)
      assert.is.not_nil(response.Outputs)
    end)

    it('- general_info API call', function()
      local response = n1:general_info()
      local expected_jver = '2.1'
      local expected_fver = '3.1.0'
      local expected_noutputs = 4

      assert.are.same(expected_jver, response.JSONVer)
      assert.are.same(expected_fver, response.Version)
      assert.are.same(expected_noutputs, response.NumOutputs)
    end)

    it('- outputs_info API call', function()
      local all_outputs = n1:outputs_info()
      local output1 = n1:outputs_info(1)
      local output2 = n1:outputs_info(2)

      assert.are.same(all_outputs[1]['ID'], output1.ID)
      assert.are.same(all_outputs[2]['ID'], output2.ID)
    end)

    it('- measure_info API call', function()
      local info = n1:info()
      
      if info.Agent.Model ~= 'NETIO 4ALL Demo' then
        assert.is_nil(n1:measure_info())
      else
        local measure = n1:measure_info()

        assert.is.not_nil(measure.Voltage)
        assert.is.not_nil(measure.Frequency)
      end
    end)

    it('- outputs_off API call with single id', function()
      local response = n1:outputs_off(1)
      local expected = 0

      assert.are.same(expected, response[1]['State'])
    end)

    it('- outputs_off API call with multiple id\'s', function()
      local response = n1:outputs_off({ 1, 2 })
      local expected = 0

      assert.are.same(expected, response[1]['State'])
      assert.are.same(expected, response[2]['State'])
    end)

    it('- outputs_on API call with single id', function()
      local response = n1:outputs_on(1)
      local expected = 1

      assert.are.same(expected, response[1]['State'])
    end)

    it('- outputs_on API call with multiple id\'s', function()
      local response = n1:outputs_on({ 1, 2 })
      local expected = 1

      assert.are.same(expected, response[1]['State'])
      assert.are.same(expected, response[2]['State'])
    end)

    it('- outputs_toggle API call with single id', function()
      local before = n1:outputs_info(1)
      local toggle = n1:outputs_toggle(1)

      assert.are.not_same(before['State'], toggle[1]['State'])
    end)

    it('- outputs_toggle API call with multiple id\'s', function()
      local response = n1:outputs_info()
      local before1 = response[1]
      local before2 = response[2]
      local toggle = n1:outputs_toggle({1, 2})

      assert.are.not_same(before1['State'], toggle[1]['State'])
      assert.are.not_same(before2['State'], toggle[2]['State'])
    end)

    it('- outputs_shortoff API call with single id and 2s delay', function()
      local response = n1:outputs_shortoff(1, 2)
      local expected1 = 0
      local expected2 = 1

      assert.are.same(expected1, response[1]['State'])
      sleep(3)
      response = n1:outputs_info()
      assert.are.same(expected2, response[1]['State'])
    end)

    it('- outputs_shortoff API call with multiple id\'s and 2s delay', function()
      local response = n1:outputs_shortoff({ 1, 2 }, 2)
      local expected1 = 0
      local expected2 = 1

      assert.are.same(expected1, response[1]['State'])
      assert.are.same(expected1, response[2]['State'])
      sleep(3)
      response = n1:outputs_info()
      assert.are.same(expected2, response[1]['State'])
      assert.are.same(expected2, response[2]['State'])
    end)

    it('- outputs_shorton API call with single id and 2s delay', function()
      local response = n1:outputs_off(1)
      response = n1:outputs_shorton(1, 2)
      local expected1 = 1
      local expected2 = 0

      assert.are.same(expected1, response[1]['State'])
      sleep(3)
      response = n1:outputs_info()
      assert.are.same(expected2, response[1]['State'])
    end)

    it('- outputs_shorton API call with multiple id\'s and 2s delay', function()
      local response = n1:outputs_off({ 1, 2 })
      response = n1:outputs_shorton({ 1, 2 }, 2)
      local expected1 = 1
      local expected2 = 0

      assert.are.same(expected1, response[1]['State'])
      assert.are.same(expected1, response[2]['State'])
      sleep(3)
      response = n1:outputs_info()
      assert.are.same(expected2, response[1]['State'])
      assert.are.same(expected2, response[2]['State'])
    end)
  end)

  describe('- #URL API', function()
    setup(function()
      -- Some test might fail, because the NETIO 4ALL sporadically rejects
      -- some requests. This rejects are not detectable because the NETIO
      -- respond with valid static information but no error at all.
      -- You can see it rejected, only by looking in the NETIO's log file.
      n1 = Netio.new({
        url = 'http://netio-4all.netio-products.com',
        port = 8080,
      })
    end)

    after_each(function()
      local resp = n1:outputs_on({ 1, 2, 3, 4 })
    end)
  
    teardown(function()
      n1 = nil
    end)

    it('- outputs_off API call with single id', function()
      local response = n1:outputs_off(1)

      assert.is_true(response)
    end)

    it('- outputs_off API call with multiple id\'s', function()
      local response = n1:outputs_off({ 1, 2 })

      assert.is_true(response)
    end)

    it('- outputs_on API call with single id', function()
      local response = n1:outputs_on(1)

      assert.is_true(response)
    end)

    it('- outputs_on API call with multiple id\'s', function()
      local response = n1:outputs_on({ 1, 2 })

      assert.is_true(response)
    end)

    it('- outputs_toggle API call with single id', function()
      local response = n1:outputs_toggle(1)

      assert.is_true(response)
    end)

    it('- outputs_toggle API call with multiple id\'s', function()
      local response = n1:outputs_toggle({1, 2})

      assert.is_true(response)
    end)

    it('- outputs_shortoff API call with single id and 2s delay', function()
      local response = n1:outputs_shortoff(1, 2)

      assert.is_true(response)
      sleep(2)
    end)

    it('- outputs_shortoff API call with multiple id\'s and 2s delay', function()
      local response = n1:outputs_shortoff({ 1, 2 }, 2)

      assert.is_true(response)
      sleep(2)
    end)

    it('- outputs_shorton API call with single id and 2s delay', function()
      local response = n1:outputs_off(1)
      assert.is_true(response)
      
      response = n1:outputs_shorton(1, 2)
      assert.is_true(response)
      sleep(2)
    end)

    it('- outputs_shorton API call with multiple id\'s and 2s delay', function()
      local response = n1:outputs_off({ 1, 2 })
      assert.is_true(response)
      
      response = n1:outputs_shorton({ 1, 2 }, 2)
      assert.is_true(response)
    end)
  end)
end)
