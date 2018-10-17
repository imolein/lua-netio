--- Some methods which are used in URL and JSON API
-- @module web_core

local utils = require('netio.utils')

local Wcore = {}
--- Perform actions on output's
--
-- @function instance:outputs_action
-- @tparam ?int|table ids The output ID where you want to perform the action. If you want to perform the same action on multiple outputs, the ID's have to be in a table
-- @tparam ?int|string action The action you want to perform (**0** or **'off'**, **1** or **'on'**, **2** or **'soff'**, **3** or **'son'**, **4** or **'toggle'**, **5** or **'nochange'**, **6** or **'ignore'**)
-- @int[opt=5] delay Define delay for **shorton** and **shortoff** in seconds
-- @treturn ?table|boolean|nil [Outputs table](../manual/dstructures.md.html#Ouputs_table) (**JSON**) or **true** (**URL**)
-- @treturn ?nil|string error message
-- @usage -- possible usecases
-- local resp = output_action(1, 2, 2) -- Switch off output 1 for 2 seconds
-- local resp = output_action({1, 2}, 2, 2) -- Switch off output 1 and 2 for 2 seconds
-- local resp = output_action({ {id=1, action=2, delay=2}, {id=2, action=2}, {id=3, action=4} }) -- Switch off ouput 1 for 2 seconds and output 2 for 5 (default if no value is given) and toggle output 3
function Wcore:outputs_action(ids, action, delay)
  local outputs, method

  if self.api == 'json' then
    outputs = utils.build_outputs_tbl(ids, action, delay)
    method = 'post'
  elseif self.api == 'url' then
    outputs = utils.build_outputs_query(ids, action, delay)
    outputs.pass = self.pass
    method = 'get'
  end

  local resp = utils.api_request(self, method, outputs)

  if type(resp) == 'table' and resp['Outputs'] then
    return resp['Outputs']
  end

  return resp
end

--- Switch outputs off
--
-- @function instance:outputs_off
-- @tparam ?int|table ids Output ID/ID's
-- @treturn ?table|boolean|nil [Outputs table](../manual/dstructures.md.html#Ouputs_table) (**JSON**) or **true** (**URL**)
-- @treturn ?nil|string error message
-- @usage local resp = netio1:output_off(1)
function Wcore:outputs_off(ids)
  return self:outputs_action(ids, 0)
end

--- Switch outputs on
--
-- @function instance:outputs_on
-- @tparam ?int|table ids Output ID/ID's
-- @treturn ?table|boolean|nil [Outputs table](../manual/dstructures.md.html#Ouputs_table) (**JSON**) or **true** (**URL**)
-- @treturn ?nil|string error message
-- @usage local resp = netio1:output_on(1)
function Wcore:outputs_on(ids)
  return self:outputs_action(ids, 1)
end

--- Switch outputs off for a specific timeframe
--
-- @function instance:outputs_shortoff
-- @tparam ?int|table ids Output ID/ID's
-- @int delay Delay between off and on in seconds
-- @treturn ?table|boolean|nil [Outputs table](../manual/dstructures.md.html#Ouputs_table) (**JSON**) or **true** (**URL**)
-- @treturn ?nil|string error message
-- @usage local resp = netio1:output_shortoff(1)
function Wcore:outputs_shortoff(ids, delay)
  return self:outputs_action(ids, 2, delay)
end

--- Switch outputs on for a specific timeframe
--
-- @function instance:outputs_shorton
-- @tparam ?int|table ids Output ID/ID's
-- @int delay Delay between on and off in seconds
-- @treturn ?table|boolean|nil [Outputs table](../manual/dstructures.md.html#Ouputs_table) (**JSON**) or **true** (**URL**)
-- @treturn ?nil|string error message
-- @usage local resp = netio1:output_shorton(1)
function Wcore:outputs_shorton(ids, delay)
  return self:outputs_action(ids, 3, delay)
end

--- Invert the outputs state
--
-- @function instance:outputs_toggle
-- @tparam ?int|table ids Output ID/ID's
-- @treturn ?table|boolean|nil [Outputs table](../manual/dstructures.md.html#Ouputs_table) (**JSON**) or **true** (**URL**)
-- @treturn ?nil|string error message
-- @usage local resp = netio1:output_toggle(1)
function Wcore:outputs_toggle(ids)
  return self:outputs_action(ids, 4)
end

return Wcore