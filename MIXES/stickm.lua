local input =
  {
    { "Strength", SOURCE},           -- user selects source (typically slider or knob)
    { "Interval", VALUE, 0, 100, 0 } -- interval value, default = 0.
  }

local output = { "ThrO", "AilO", "EleO", "RudO"}

local function channelOutput(code)
  if string.len(code) == 1 then
    local R = nil
    if code == "U" then
      return 0, 1 -- R = {x = col + w / 2 - 1, y = top + 2, w = 3, h = h / 2 - 4}
    elseif code == "D" then
      return 0, -1 -- R = {x = col + w / 2 - 1, y = top + h / 2 + 2, w = 3, h = h / 2 - 4}
    elseif code == "L" then
      return -1, 0 -- R = {x = col + 2, y = top + h / 2 - 1, w = w / 2 - 4, h = 3}
    elseif code == "R" then
      return 1, 0 -- R = {x = col + w / 2 + 4, y = top + h / 2 - 1, w = w / 2 - 4, h = 3}
    elseif code == "C" then
      return 0, 0 -- R = {x = col + w / 2 - 2, y = top + h / 2 - 2, w = 5, h = 5}
    end
    if R ~= nil then
      -- lcd.drawFilledRectangle(R["x"], R["y"], R["w"], R["h"])
    else
      print("bad stick code " .. code)
    end
  else
    local L = nil
    if code == "UL" then
      return -1, 1 -- L = {x1 = col + 2, y1 = top + 2, x2 = col + w / 2 - 4, y2 = top + h / 2 - 4}
    elseif code == "UR" then
      return 1, 1 -- L = {x1 = col + w - 2, y1 = top + 2, x2 = col + w / 2 + 4, y2 = top + h / 2 - 4}
    elseif code == "DR" then
      return 1, -1 -- L = {x1 = col + w - 2, y1 = top + h - 2, x2 = col + w / 2 + 4, y2 = top + h / 2 + 4}
    elseif code == "DL" then
      return -1, -1 -- L = {x1 = col + 2, y1 = top + h - 2, x2 = col + w / 2 - 4, y2 = top + h / 2 + 4}
    end
    if L ~= nil then
      -- lcd.drawLine(L["x1"], L["y1"], L["x2"], L["y2"], SOLID, INVERS)
    else
      print("bad stick code " .. code)
    end
  end
end

local function init()
  -- Called once when the script is loaded
end

local function run(Strength, Interval) -- Must match input table
  -- local v1, v2
  -- Called periodically
  -- return v1, v2                        -- Must match output table
  local v = getLogicalSwitchValue(0)
  --return Strength * Interval / 100, v and 1 or 0
  code1, code2 = "UL", "U"
  a, b = channelOutput(code1)
  c, d = channelOutput(code2)
  return a * 1024, b * 1024, c * 1024, d * 1024
end

return { input=input, output=output, run=run, init=init }
