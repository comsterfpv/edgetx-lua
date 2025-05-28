-- TNS|Stick Commands|TNE
local exitscript = 0

local group_count = nil
local group_index = 0
local command_index = 0
local left_col = nil
local right_col = nil
local top = nil
local w = nil
local h = nil
local label_row = nil

commands = { -- FC commands are valid in both Betaflight and INAV
  {"FC", "Calibrate ACC", "UL", "D"},
  {"FC", "Calibrate Gyro", "DL", "D"},
  {"FC", "Calibrate Compass", "UR", "D"},
  {"FC", "Profile 1", "DL", "L"},
  {"FC", "Profile 2", "DL", "U"},
  {"FC", "Profile 3", "DL", "R"},
  {"FC", "Trim ACC Left", "U", "L"},
  {"FC", "Trim ACC Right", "U", "R"},
  {"FC", "Trim ACC Forwards", "U", "U"},
  {"FC", "Trim ACC Backwards", "U", "D"},
  {"FC", "Enter OSD Menu", "L", "U", "ifosdm"},
  {"FC", "Save Settings", "DL", "DR"},
  {"INAV", "Bat Profile 1", "UL", "L"},
  {"INAV", "Bat Profile 2", "UL", "U"},
  {"INAV", "Bat Profile 3", "UL", "R"},
  {"INAV", "Load Waypoint Mission", "D", "UR", "iflwpm"},
  {"INAV", "Save Waypoint Mission", "D", "UL"},
  {"INAV", "Unload Waypoint Mission", "D", "DR"},
  {"HDZero", "VTX Menu", "DR", "DL"},
  {"HDZero", "Camera Menu", "R", "C"},
  {"HDZero", "Pit Mode", "UL", "UR"}, -- this is OPT_B, check on OPT_A
}

-- groups = {
--   {"FC", commands_fc},
--   {"INAV", commands_inav},
--   {"HDZero", commands_hdzero},
-- }

local function drawGimbal(col, top, w, h)
  lcd.drawRectangle(col, top, w, h)
  lcd.drawLine(col + w / 2, top + 2, col + w / 2, top + 10, DOTTED, INVERS)
  lcd.drawLine(col + w / 2, top + h - 2, col + w / 2, top + h - 10, DOTTED, INVERS)
  lcd.drawLine(col + 2, top + h / 2, col + 10, top + h / 2, DOTTED, INVERS)
  lcd.drawLine(col + w - 2, top + h / 2, col + w - 10, top + h / 2, DOTTED, INVERS)
end

local function drawStick(col, top, w, h, code)
  if string.len(code) == 1 then
    local R = nil
    if code == "U" then
      R = {x = col + w / 2 - 1, y = top + 2, w = 3, h = h / 2 - 4}
    elseif code == "D" then
      R = {x = col + w / 2 - 1, y = top + h / 2 + 2, w = 3, h = h / 2 - 4}
    elseif code == "L" then
      R = {x = col + 2, y = top + h / 2 - 1, w = w / 2 - 4, h = 3}
    elseif code == "R" then
      R = {x = col + w / 2 + 4, y = top + h / 2 - 1, w = w / 2 - 4, h = 3}
    elseif code == "C" then
      R = {x = col + w / 2 - 2, y = top + h / 2 - 2, w = 5, h = 5}
    end
    if R ~= nil then
      lcd.drawFilledRectangle(R["x"], R["y"], R["w"], R["h"])
    else
      print("bad stick code " .. code)
    end
  else
    local L = nil
    if code == "UL" then
      L = {x1 = col + 2, y1 = top + 2, x2 = col + w / 2 - 4, y2 = top + h / 2 - 4}
    elseif code == "UR" then
      L = {x1 = col + w - 2, y1 = top + 2, x2 = col + w / 2 + 4, y2 = top + h / 2 - 4}
    elseif code == "DR" then
      L = {x1 = col + w - 2, y1 = top + h - 2, x2 = col + w / 2 + 4, y2 = top + h / 2 + 4}
    elseif code == "DL" then
      L = {x1 = col + 2, y1 = top + h - 2, x2 = col + w / 2 - 4, y2 = top + h / 2 + 4}
    end
    if L ~= nil then
      lcd.drawLine(L["x1"], L["y1"], L["x2"], L["y2"], SOLID, INVERS)
    else
      print("bad stick code " .. code)
    end
  end
end

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

local function drawStickCommand(code1, code2)
  drawGimbal(left_col, top, w, h)
  drawStick(left_col, top, w, h, code1)
  drawGimbal(right_col, top, w, h)
  drawStick(right_col, top, w, h, code2)
end

local function drawState()
  -- local group_tuple = groups[group_index]
  -- group_str = group_tuple[1]
  -- command_dict = groups[group_index][2]
  command_dict = commands[command_index]
  group_str = command_dict[1]
  command_str = command_dict[2]
  command_code1 = command_dict[3]
  command_code2 = command_dict[4]
  drawStickCommand(command_code1, command_code2)
  lcd.drawText(1, label_row, command_str)
  lcd.drawText(1, 0, "Stick Cmd: " .. group_str, INVERS)
end

local function identifySpecialFunc()
  -- print("FOC = ", FUNC_OVERRIDE_CHANNEL)
  local specialFuncs = {}
  for i = 0, 63 do
    info = model.getCustomFunction(i)
    if info ~= nil then
      if info['active'] == 1 and info['func'] == FUNC_OVERRIDE_CHANNEL then
      -- if info['func'] == FUNC_OVERRIDE_CHANNEL then
      -- if info['func'] == 130 then
        print("switch, func, value, mode, param, active = ", info['switch'], info['func'], info["value"], info["mode"], info["param"], info["active"])
        chan = info["param"] + 1
        if chan == 1 or chan == 2 or chan == 3 or chan == 4 then
          print("found specialFunc ", chan)
          specialFuncs[chan] = {index = i, switch = info["switch"]}
        end
      end
    end
  end
  print("#specialFuncs = ", #specialFuncs)

  if #specialFuncs ~= 4 then
    print("not enough channel overrides")
    return
  end

  switch_index = specialFuncs[1]["switch"]
  for chan = 2, 4 do
    if specialFuncs[chan]["switch"] ~= switch_index then
      print("inconsistent channel override switches")
      return
    end
  end
  switch = getSwitchName(switch_index)
  logical_index = tonumber(string.sub(switch, 2)) - 1
  setStickySwitch(logical_index, true)
  -- print(getSwitchName(switch))
  info = model.getLogicalSwitch(logical_index)
  for k, v in pairs(info) do
    print(k, v)
  end
end

local function handleEventOld(event)
  if event == EVT_VIRTUAL_PREV then
    command_index = command_index - 1
    if command_index <= 0 then
      group_index = group_index - 1
      if group_index <= 0 then
        group_index = #groups
      end
      command_dict_new = groups[group_index][2]
      command_index = #command_dict_new
    end
  elseif event == EVT_VIRTUAL_NEXT then
    command_index = command_index + 1
    command_dict = groups[group_index][2]
    if command_index > #command_dict then
      group_index = group_index + 1
      if group_index >= #groups then
        group_index = 1
      end
      command_index = 1
    end
  end
end

local function handleEvent(event)
  if event == EVT_VIRTUAL_PREV then
    command_index = command_index - 1
    if command_index <= 0 then
      command_index = #commands
    end
  elseif event == EVT_VIRTUAL_NEXT then
    command_index = command_index + 1
    if command_index > #commands then
      command_index = 1
    end
  end
end

-- Init
local function init()
  -- group_count = #groups
  -- group_index = 1
  command_index = 1
  left_col = 10
  right_col = 60
  top = 12
  w = 40
  h = 40
  label_row = top + h + 4

  identifySpecialFunc()
end

-- Main
local function run(event, touchState)
  if event == nil then return 2 end

  handleEvent(event)

  lcd.clear()
  drawState()

  return exitscript
end

return { init=init, run=run }
