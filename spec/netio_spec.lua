package.path = package.path .. ';./?/init.lua'

local netio, n1

describe('lua-netio', function()
  setup(function()
    netio = require('netio')
  end)

  teardown(function()
    netio = nil
  end)

  before_each(function()
    n1 = netio.new({
      url = 'http://netio-4.netio-products.com/',
      port = 8080,
      user = 'write',
      passwd = 'demo'
    })
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

  it('- output_info API call', function()
    local all_outputs = n1:output_info()
    local output1 = n1:output_info(1)
    local output2 = n1:output_info(2)
    
    assert.are.same(all_outputs[1]['ID'], output1.ID)
    assert.are.same(all_outputs[2]['ID'], output2.ID)
  end)

  it('- output_on API call with single id', function()
    local on = n1:output_off(1)
    local expected = 0
    
    assert.are.same(expected, on.Outputs[1]['State'])
  end)

  it('- output_on API call with multiple id\'s', function()
    local on = n1:output_off({1, 2})
    local expected = 0
    
    assert.are.same(expected, on.Outputs[1]['State'])
    assert.are.same(expected, on.Outputs[2]['State'])
  end)

  it('- output_on API call with single id', function()
    local on = n1:output_on(1)
    local expected = 1
    
    assert.are.same(expected, on.Outputs[1]['State'])
  end)

  it('- output_on API call with multiple id\'s', function()
    local on = n1:output_on({1, 2})
    local expected = 1
    
    assert.are.same(expected, on.Outputs[1]['State'])
    assert.are.same(expected, on.Outputs[2]['State'])
  end)

  it('- output_toggle API call with single id', function()
    local before = n1:output_info(1)
    local toggle = n1:output_toggle(1)
    
    assert.are.not_same(before['State'], toggle.Outputs[1]['State'])
  end)

  it('- output_toggle API call with multiple id\'s', function()
    local response = n1:output_info()
    local before1 = response[1]
    local before2 = response[2]
    local toggle = n1:output_toggle({1, 2})
    
    assert.are.not_same(before1['State'], toggle.Outputs[1]['State'])
    assert.are.not_same(before2['State'], toggle.Outputs[2]['State'])
  end)

end)


