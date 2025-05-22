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

commands_fc = { -- these are good in both Betaflight and INAV
  {"Calibrate ACC", "UL", "D"},
  {"Calibrate Gyro", "DL", "D"},
  {"Calibrate Compass", "UR", "D"},
  {"Profile 1", "DL", "L"},
  {"Profile 2", "DL", "U"},
  {"Profile 3", "DL", "R"},
  {"Trim ACC Left", "U", "L"},
  {"Trim ACC Right", "U", "R"},
  {"Trim ACC Forwards", "U", "U"},
  {"Trim ACC Backwards", "U", "D"},
  {"Enter OSD Menu", "L", "U"},
  {"Save Settings", "DL", "DR"},
}

commands_inav = {
  {"Bat Profile 1", "UL", "L"},
  {"Bat Profile 2", "UL", "U"},
  {"Bat Profile 3", "UL", "R"},
  {"Load Waypoint Mission", "D", "UR"},
  {"Save Waypoint Mission", "D", "UL"},
  {"Unload Waypoint Mission", "D", "DR"},
}

commands_hdzero = {
  {"VTX Menu", "DR", "DL"},
  {"Camera Menu", "R", "C"},
  {"Pit Mode", "UL", "UR"}, -- this is OPT_B, check on OPT_A
}

groups = {
  {"FC", commands_fc},
  {"INAV", commands_inav},
  {"HDZero", commands_hdzero},
}

local function drawHeader()
end

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

local function drawStickCommand(code1, code2)
  drawGimbal(left_col, top, w, h)
  drawStick(left_col, top, w, h, code1)
  drawGimbal(right_col, top, w, h)
  drawStick(right_col, top, w, h, code2)
end

local function drawState()
  local group_tuple = groups[group_index]
  group_str = group_tuple[1]
  command_dict = groups[group_index][2]
  command_str = command_dict[command_index][1]
  command_code1 = command_dict[command_index][2]
  command_code2 = command_dict[command_index][3]
  drawStickCommand(command_code1, command_code2)
  lcd.drawText(1, label_row, command_str)
  lcd.drawText(1, 0, "Stick Cmd: " .. group_str, INVERS)
end

local function handleEvent(event)
  if event == EVT_VIRTUAL_PREV then
    if command_index <= 1 then
      group_index = group_index - 1
      if group_index <= 0 then
        group_index = #groups
      end
      command_dict_new = groups[group_index][2]
      command_index = #command_dict_new
    else
      command_index = command_index - 1
    end
  elseif event == EVT_VIRTUAL_NEXT then
    command_dict = groups[group_index][2]
    if command_index >= #command_dict then
      group_index = group_index + 1
      command_index = 0
    end
    if group_index > #groups then
      group_index = 1
    end

    command_index = command_index + 1
  end
end

-- Init
local function init()
  group_count = #groups
  group_index = 1
  command_index = 1
  left_col = 10
  right_col = 60
  top = 12
  w = 40
  h = 40
  label_row = top + h + 4
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
