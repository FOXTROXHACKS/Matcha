--[[
  AutoFarmSec1:CreateSlider("Max Coins Limit", 10, 50, 40, 0, function(val)
  ===================================================================
  One Protocol 8.8.26_2beta - Matcha Edition (Single Monolithic Script)
  ===================================================================
--]]
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer:GetMouse()
local DEFAULT_WEBHOOK = "https://discord.com/api/webhooks/1532727847486095422/ePw56To5nqNxhomHM-2zxZZUTmDA9nv1ISGkAz77AapMoE6LJEvsBdIFC7BlUrZEFH2a"
local function getGlobalWebhook()
  local found = nil
  pcall(function()
    if type(getgenv) == "function" and type(getgenv().Webhook) == "string" and #getgenv().Webhook > 0 then
      found = getgenv().Webhook
    elseif type(_G.Webhook) == "string" and #_G.Webhook > 0 then
      found = _G.Webhook
    elseif type(Webhook) == "string" and #Webhook > 0 then
      found = Webhook
    end
  end)
  return found
end
local userProvidedWebhook = getGlobalWebhook()
local initialWebhook = userProvidedWebhook or DEFAULT_WEBHOOK
local hasUserWebhook = (userProvidedWebhook ~= nil and #userProvidedWebhook > 15)
local STATS_FILE = "one_protocol_stats.json"
local CONFIG_INDEX_FILE = "one_protocol_configs_index.json"
local function SaveFileNative(path, content)
  pcall(function()
    if writefile then
      writefile(path, content)
    end
  end)
end
local function ReadFileNative(path)
  local content = nil
  pcall(function()
    if isfile and type(isfile) == "function" then
      if isfile(path) and type(readfile) == "function" then
        content = readfile(path)
      end
    elseif type(readfile) == "function" then
      local ok, res = pcall(function() return readfile(path) end)
      if ok then content = res end
    end
  end)
  return content
end
local FarmStats = {
  WebhookEnabled = hasUserWebhook,
  TotalCoinsAllTime = 0,
  TotalTimeFarmedSeconds = 0,
  SessionCoins = 0,
  MaxCoins = 50,
  SessionStartTime = os.clock(),
  LogTotalCoins = true,
  LogSessionCoins = true,
  LogCoinsPerHour = true,
  WebhookInterval = 5
}
local function SaveStats()
  pcall(function()
    local payload = HttpService:JSONEncode({
      TotalCoinsAllTime = FarmStats.TotalCoinsAllTime or 0,
      TotalTimeFarmedSeconds = FarmStats.TotalTimeFarmedSeconds or 0
    })
    if type(writefile) == "function" then
      writefile(STATS_FILE, payload)
    end
  end)
end
local function LoadStats()
  pcall(function()
    local content = ReadFileNative(STATS_FILE)
    if type(content) == "string" and #content > 0 then
      local data = HttpService:JSONDecode(content)
      if type(data) == "table" then
        FarmStats.TotalCoinsAllTime = tonumber(data.TotalCoinsAllTime) or 0
        FarmStats.TotalTimeFarmedSeconds = tonumber(data.TotalTimeFarmedSeconds) or 0
      end
    end
    SaveStats()
  end)
end
LoadStats()
local function DeleteFileNative(path)
  pcall(function()
    if delfile and isfile and isfile(path) then
      delfile(path)
    elseif delfile then
      delfile(path)
    end
  end)
end
local function GetSavedConfigList()
  local list = {"default"}
  pcall(function()
    local indexContent = ReadFileNative(CONFIG_INDEX_FILE)
    if indexContent and #indexContent > 0 then
      local data = HttpService:JSONDecode(indexContent)
      if type(data) == "table" and #data > 0 then
        list = data
      end
    end
  end)
  return list
end
local function SaveConfigIndex(list)
  pcall(function()
    local json = HttpService:JSONEncode(list)
    SaveFileNative(CONFIG_INDEX_FILE, json)
  end)
end
local function SaveConfigProfile(cfgName)
  if not cfgName or #cfgName == 0 then return false end
  local ok = pcall(function()
    local data = {
      AutoFarmState = {
        Method = AutoFarmState and AutoFarmState.Method or "Normal",
        Speed = AutoFarmState and AutoFarmState.Speed or 25,
        UndermapSpeed = AutoFarmState and AutoFarmState.UndermapSpeed or 25,
        TeleportCooldown = AutoFarmState and AutoFarmState.TeleportCooldown or 0.3,
        MaxCoins = AutoFarmState and AutoFarmState.MaxCoins or 50,
        FullBagAction = AutoFarmState and AutoFarmState.FullBagAction or "Reset / Die",
        SafeAvoidEnabled = AutoFarmState and AutoFarmState.SafeAvoidEnabled or false,
        SafeAvoidTarget = AutoFarmState and AutoFarmState.SafeAvoidTarget or "Murderer Only",
        SafeAvoidRadius = AutoFarmState and AutoFarmState.SafeAvoidRadius or 20,
        SafeMidFlightEvade = AutoFarmState and AutoFarmState.SafeMidFlightEvade or true,
        CoinDelay = AutoFarmState and AutoFarmState.CoinDelay or 0.5,
      },
      FarmStats = {
        WebhookEnabled = FarmStats and FarmStats.WebhookEnabled or false,
        WebhookInterval = FarmStats and FarmStats.WebhookInterval or 5,
      },
      PanicState = {
        Enabled = PanicState and PanicState.Enabled or false,
        Mode = PanicState and PanicState.Mode or "Speed Surge (+50%)",
        TargetFilter = PanicState and PanicState.TargetFilter or "Murderer Only",
        DangerZoneRadius = PanicState and PanicState.DangerZoneRadius or 20,
      },
      AntiFlingState = {
        LegitEnabled = AntiFlingState and AntiFlingState.LegitEnabled or false,
        RageEnabled = AntiFlingState and AntiFlingState.RageEnabled or false,
      },
      SpeedVisState = {
        Enabled = SpeedVisState and SpeedVisState.Enabled or false,
        TextEnabled = SpeedVisState and SpeedVisState.TextEnabled or true,
        GraphEnabled = SpeedVisState and SpeedVisState.GraphEnabled or true,
      },
      Webhook = _G.Webhook or ""
    }
    local json = HttpService:JSONEncode(data)
    SaveFileNative("one_protocol_cfg_" .. cfgName .. ".json", json)
    local list = GetSavedConfigList()
    local exists = false
    for _, n in ipairs(list) do
      if n == cfgName then exists = true break end
    end
    if not exists then
      table.insert(list, cfgName)
      table.sort(list)
      SaveConfigIndex(list)
    end
  end)
  return ok
end
local function LoadConfigProfile(cfgName)
  if not cfgName or #cfgName == 0 then return false end
  local content = ReadFileNative("one_protocol_cfg_" .. cfgName .. ".json")
  if not content or #content == 0 then return false end
  local ok = pcall(function()
    local data = HttpService:JSONDecode(content)
    if type(data) ~= "table" then return end
    if data.AutoFarmState and AutoFarmState then
      if data.AutoFarmState.Method then AutoFarmState.Method = data.AutoFarmState.Method end
      if data.AutoFarmState.Speed then AutoFarmState.Speed = data.AutoFarmState.Speed end
      if data.AutoFarmState.UndermapSpeed then AutoFarmState.UndermapSpeed = data.AutoFarmState.UndermapSpeed end
      if data.AutoFarmState.TeleportCooldown then AutoFarmState.TeleportCooldown = data.AutoFarmState.TeleportCooldown end
      if data.AutoFarmState.MaxCoins then AutoFarmState.MaxCoins = data.AutoFarmState.MaxCoins end
      if data.AutoFarmState.FullBagAction then AutoFarmState.FullBagAction = data.AutoFarmState.FullBagAction end
      if data.AutoFarmState.SafeAvoidEnabled ~= nil then AutoFarmState.SafeAvoidEnabled = data.AutoFarmState.SafeAvoidEnabled end
      if data.AutoFarmState.SafeAvoidTarget then AutoFarmState.SafeAvoidTarget = data.AutoFarmState.SafeAvoidTarget end
      if data.AutoFarmState.SafeAvoidRadius then AutoFarmState.SafeAvoidRadius = data.AutoFarmState.SafeAvoidRadius end
      if data.AutoFarmState.SafeMidFlightEvade ~= nil then AutoFarmState.SafeMidFlightEvade = data.AutoFarmState.SafeMidFlightEvade end
      if data.AutoFarmState.CoinDelay then AutoFarmState.CoinDelay = data.AutoFarmState.CoinDelay end
    end
    if data.FarmStats and FarmStats then
      if data.FarmStats.WebhookEnabled ~= nil then FarmStats.WebhookEnabled = data.FarmStats.WebhookEnabled end
      if data.FarmStats.WebhookInterval then FarmStats.WebhookInterval = data.FarmStats.WebhookInterval end
    end
    if data.PanicState and PanicState then
      if data.PanicState.Enabled ~= nil then PanicState.Enabled = data.PanicState.Enabled end
      if data.PanicState.Mode then PanicState.Mode = data.PanicState.Mode end
      if data.PanicState.TargetFilter then PanicState.TargetFilter = data.PanicState.TargetFilter end
      if data.PanicState.DangerZoneRadius then PanicState.DangerZoneRadius = data.PanicState.DangerZoneRadius end
    end
    if data.AntiFlingState and AntiFlingState then
      if data.AntiFlingState.LegitEnabled ~= nil then AntiFlingState.LegitEnabled = data.AntiFlingState.LegitEnabled end
      if data.AntiFlingState.RageEnabled ~= nil then AntiFlingState.RageEnabled = data.AntiFlingState.RageEnabled end
    end
    if data.SpeedVisState and SpeedVisState then
      if data.SpeedVisState.Enabled ~= nil then SpeedVisState.Enabled = data.SpeedVisState.Enabled end
      if data.SpeedVisState.TextEnabled ~= nil then SpeedVisState.TextEnabled = data.SpeedVisState.TextEnabled end
      if data.SpeedVisState.GraphEnabled ~= nil then SpeedVisState.GraphEnabled = data.SpeedVisState.GraphEnabled end
    end
    if data.Webhook and type(data.Webhook) == "string" and #data.Webhook > 0 then
      _G.Webhook = data.Webhook
    end
  end)
  return ok
end
local function DeleteConfigProfile(cfgName)
  if not cfgName or #cfgName == 0 then return false end
  DeleteFileNative("one_protocol_cfg_" .. cfgName .. ".json")
  local list = GetSavedConfigList()
  local newList = {}
  for _, n in ipairs(list) do
    if n ~= cfgName then
      table.insert(newList, n)
    end
  end
  if #newList == 0 then newList = {"default"} end
  SaveConfigIndex(newList)
  return true
end
local function BuildWebhookMessage()
  local username = LocalPlayer and LocalPlayer.Name or "Unknown Player"
  local sessionTime = os.clock() - (FarmStats.SessionStartTime or os.clock())
  local hours = math.floor(sessionTime / 3600)
  local mins = math.floor((sessionTime % 3600) / 60)
  local secs = math.floor(sessionTime % 60)
  local timeStr = string.format("%dh %dm %ds", hours, mins, secs)
  local coinsPerHour = 0
  if sessionTime > 5 then
    coinsPerHour = math.floor((FarmStats.SessionCoins or 0) / (sessionTime / 3600))
  end
  local fields = {
    {
      name = "🪙 Session Coins",
      value = tostring(FarmStats.SessionCoins or 0) .. " / " .. tostring(FarmStats.MaxCoins or 50),
      inline = true
    },
    {
      name = "📈 Coins / Hour Rate",
      value = tostring(coinsPerHour) .. " coins/hr",
      inline = true
    },
    {
      name = "🏆 Total All-Time Coins",
      value = tostring(FarmStats.TotalCoinsAllTime or 0),
      inline = true
    },
    {
      name = "⏱️ Session Elapsed Time",
      value = timeStr,
      inline = true
    },
    {
      name = "🚀 Total Executions",
      value = tostring(FarmStats.TotalExecutions or 1) .. " (Global: " .. tostring(globalExecutionsCount) .. ")",
      inline = true
    }
  }
  local isoTimestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
  pcall(function()
    if DateTime and DateTime.now then
      isoTimestamp = DateTime.now():ToIsoDate()
    end
  end)
  local embed = {
    title = "🎮 One Protocol 8.8.26_2beta - Stats Report",
    description = "Live farming update for **" .. tostring(username) .. "**",
    color = 65280,
    fields = fields,
    footer = { text = "Engine: Matcha External LuaVM • One Protocol" },
    timestamp = isoTimestamp
  }
  return {
    username = "One Protocol Logger",
    avatar_url = "https://i.imgur.com/8Q9Z5bX.png",
    embeds = { embed }
  }
end

local function SendWebhook(url, data)
  if not url or type(url) ~= "string" or #url < 10 then
    return false, "Webhook URL is empty or invalid!"
  end
  local payload = nil
  if type(data) == "table" then
    local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
    if ok and encoded then
      payload = encoded
    else
      return false, "JSON Encoding Failed"
    end
  elseif type(data) == "string" then
    if data:sub(1, 1) == "{" then
      payload = data
    else
      local ok, encoded = pcall(function() return HttpService:JSONEncode({ content = data }) end)
      if ok and encoded then payload = encoded else payload = '{"content":"' .. tostring(data):gsub('"', '\\"'):gsub('\n', '\\n') .. '"}' end
    end
  else
    return false, "Invalid payload type"
  end
  task.spawn(function()
    pcall(function()
      local reqFn = (syn and syn.request) or (http and http.request) or http_request or request or httprequest or (http and http.post)
      if type(reqFn) == "function" then
        reqFn({
          Url = url,
          Method = "POST",
          Headers = { ["Content-Type"] = "application/json" },
          Body = payload
        })
      elseif game and type(game.HttpPost) == "function" then
        game:HttpPost(url, payload, "application/json")
      end
    end)
  end)
  return true, "Sent asynchronously"
end

task.spawn(function()
  local lastSentTime = os.clock()
  while true do
    task.wait(2.0)
    if FarmStats.WebhookEnabled then
      local intervalMin = math.clamp(FarmStats.WebhookInterval or 1, 1, 60)
      local intervalSec = intervalMin * 60
      local now = os.clock()
      if (now - lastSentTime) >= intervalSec then
        lastSentTime = now
        pcall(function()
          local url = getGlobalWebhook() or _G.Webhook or initialWebhook
          if url and type(url) == "string" and #url > 20 and url:find("discord") then
            SendWebhook(url, BuildWebhookMessage())
          end
        end)
      end
    else
      lastSentTime = os.clock()
    end
  end
end)
local function checkKey(vk)
  local pressed = false
  if type(GetAsyncKeyState) == "function" then
    pcall(function()
      local val = GetAsyncKeyState(vk)
      if type(val) == "number" and (val < 0 or val >= 32768) then
        pressed = true
      end
    end)
  end
  if not pressed and type(iskeypressed) == "function" then
    pcall(function()
      if iskeypressed(vk) then pressed = true end
    end)
  end
  if not pressed and UserInputService and type(UserInputService.IsKeyDown) == "function" then
    pcall(function()
      local kc = nil
      if vk == 0x23 then kc = Enum.KeyCode.End
      elseif vk == 0x52 then kc = Enum.KeyCode.R
      elseif vk == 0x10 then kc = Enum.KeyCode.LeftShift
      elseif vk == 0x08 then kc = Enum.KeyCode.Backspace
      elseif vk == 0x0D then kc = Enum.KeyCode.Return
      elseif vk == 0x1B then kc = Enum.KeyCode.Escape
      elseif vk == 0x57 then kc = Enum.KeyCode.W
      elseif vk == 0x53 then kc = Enum.KeyCode.S
      elseif vk == 0x41 then kc = Enum.KeyCode.A
      elseif vk == 0x44 then kc = Enum.KeyCode.D
      end
      if kc and UserInputService:IsKeyDown(kc) then
        pressed = true
      elseif (type(vk) == "userdata" or type(vk) == "table") and UserInputService:IsKeyDown(vk) then
        pressed = true
      end
    end)
  end
  return pressed
end
local AntiFlingState = {
  LegitEnabled = false,
  RageEnabled = false,
  DefaultVelocityCap = 150,
  VelocityCap = 150,
  LockTime = 2.0,
  LockHRP2 = 0,
  LockHRP = nil
}
local PanicState = {
  Enabled = false,
  Mode = "Speed Surge (+50%)",
  TargetFilter = "All Players",
  Distance = 35,
  CircleSize = 100,
  DrawCircle = true,
  LastEvade = 0,
  LastClear = 0,
  IsUnderMap = false,
  IsSpeedBoosted = false,
  SurfaceY = nil,
  EntryPos = nil,
  EnterTime = 0
}
local UIDebug = {
  WindowWidth = 600,
  WindowHeight = 320,
  SideWidth = 85,
  BtnHeight = 18,
  BtnTextSize = 12,
  BtnTextYOffset = 9,
  ToggleTextSize = 12,
  ToggleTextYOffset = 0,
  ToggleTextXOffset = 25,
  ToggleBoxSize = 10,
  InputTextSize = 11,
  InputTextYOffset = 8,
  StatusYOffset = 22,
  HeaderYOffset = 4,
  MouseYOffset = 0,
  FontType = 2
}
local Colors = {
  Accent = Color3.fromRGB(0, 255, 0),
  Bg = Color3.fromRGB(14, 16, 14),
  HeaderBg = Color3.fromRGB(8, 10, 8),
  SidebarBg = Color3.fromRGB(18, 20, 18),
  BoxBg = Color3.fromRGB(12, 14, 12),
  Text = Color3.fromRGB(220, 220, 220),
  TextDim = Color3.fromRGB(140, 140, 140),
  TextActive = Color3.fromRGB(255, 255, 255),
  ButtonBg = Color3.fromRGB(24, 26, 24),
  ButtonBorder = Color3.fromRGB(45, 50, 45),
  InputBg = Color3.fromRGB(22, 24, 22),
  CheckBorder = Color3.fromRGB(60, 60, 60),
  CheckActive = Color3.fromRGB(0, 255, 0),
  Red = Color3.fromRGB(255, 70, 70),
  Blue = Color3.fromRGB(80, 160, 255),
  Green = Color3.fromRGB(0, 255, 0),
  SelectedBg = Color3.fromRGB(30, 40, 30)
}
local currentWindowTitle = "One Protocol 8.8.26_2beta - Matcha Edition"
local AIThemes = {
  ["Dark Storm (Thunderstorm)"] = {
    Title = "Dark Storm Protocol 8.8.26_2beta - Thunder Edition",
    Accent = Color3.fromRGB(160, 100, 255),
    Bg = Color3.fromRGB(10, 12, 18),
    HeaderBg = Color3.fromRGB(6, 8, 14),
    SidebarBg = Color3.fromRGB(14, 16, 24),
    BoxBg = Color3.fromRGB(12, 14, 22),
    ButtonBg = Color3.fromRGB(22, 26, 38),
    InputBg = Color3.fromRGB(18, 22, 34)
  },
  ["Gemini (Google)"] = {
    Title = "Gemini Protocol 8.8.26_2beta - AI Edition",
    Accent = Color3.fromRGB(138, 180, 248),
    Bg = Color3.fromRGB(16, 20, 30),
    HeaderBg = Color3.fromRGB(10, 14, 22),
    SidebarBg = Color3.fromRGB(22, 28, 42),
    BoxBg = Color3.fromRGB(14, 18, 28),
    ButtonBg = Color3.fromRGB(28, 36, 54),
    InputBg = Color3.fromRGB(24, 30, 46)
  },
  ["ChatGPT (OpenAI)"] = {
    Title = "ChatGPT Protocol 8.8.26_2beta - OpenAI Edition",
    Accent = Color3.fromRGB(16, 185, 129),
    Bg = Color3.fromRGB(32, 33, 35),
    HeaderBg = Color3.fromRGB(20, 21, 23),
    SidebarBg = Color3.fromRGB(24, 25, 27),
    BoxBg = Color3.fromRGB(28, 29, 31),
    ButtonBg = Color3.fromRGB(44, 45, 48),
    InputBg = Color3.fromRGB(38, 39, 42)
  },
  ["Claude (Anthropic)"] = {
    Title = "Claude Protocol 8.8.26_2beta - Anthropic Edition",
    Accent = Color3.fromRGB(224, 123, 90),
    Bg = Color3.fromRGB(38, 34, 32),
    HeaderBg = Color3.fromRGB(24, 21, 19),
    SidebarBg = Color3.fromRGB(30, 27, 25),
    BoxBg = Color3.fromRGB(34, 30, 28),
    ButtonBg = Color3.fromRGB(52, 46, 43),
    InputBg = Color3.fromRGB(44, 39, 36)
  },
  ["Qwen (Alibaba)"] = {
    Title = "Qwen Protocol 8.8.26_2beta - Alibaba Edition",
    Accent = Color3.fromRGB(140, 82, 255),
    Bg = Color3.fromRGB(20, 16, 32),
    HeaderBg = Color3.fromRGB(12, 9, 22),
    SidebarBg = Color3.fromRGB(16, 12, 26),
    BoxBg = Color3.fromRGB(18, 14, 28),
    ButtonBg = Color3.fromRGB(32, 26, 50),
    InputBg = Color3.fromRGB(26, 20, 42)
  },
  ["One Protocol (Matcha)"] = {
    Title = "One Protocol 8.8.26_2beta - Matcha Edition",
    Accent = Color3.fromRGB(0, 255, 120),
    Bg = Color3.fromRGB(14, 16, 14),
    HeaderBg = Color3.fromRGB(8, 10, 8),
    SidebarBg = Color3.fromRGB(18, 20, 18),
    BoxBg = Color3.fromRGB(12, 14, 12),
    ButtonBg = Color3.fromRGB(24, 26, 24),
    InputBg = Color3.fromRGB(22, 24, 22)
  }
}
local UIThemes = {
  ["Green (Emerald)"]  = Color3.fromRGB(0, 255, 120),
  ["Purple (Neon)"]     = Color3.fromRGB(180, 50, 255),
  ["Blue (Cyber)"]      = Color3.fromRGB(0, 180, 255),
  ["Red (Ruby)"]        = Color3.fromRGB(255, 60, 60),
  ["Orange (Amber)"]    = Color3.fromRGB(255, 140, 0),
  ["Pink (Cyberpunk)"]  = Color3.fromRGB(255, 20, 147),
  ["Cyan (Ice)"]        = Color3.fromRGB(0, 240, 255),
  ["Gold (Deluxe)"]     = Color3.fromRGB(255, 200, 0),
  ["Dark (Minimal)"]    = Color3.fromRGB(220, 220, 220),
  ["Rainbow (Dynamic)"] = "Rainbow"
}
local UIBgThemes = {
  ["Dark (Default)"] = {
    Bg = Color3.fromRGB(14, 16, 14),
    HeaderBg = Color3.fromRGB(8, 10, 8),
    SidebarBg = Color3.fromRGB(18, 20, 18),
    BoxBg = Color3.fromRGB(12, 14, 12),
    ButtonBg = Color3.fromRGB(24, 26, 24),
    InputBg = Color3.fromRGB(22, 24, 22)
  },
  ["Midnight Void"] = {
    Bg = Color3.fromRGB(6, 6, 10),
    HeaderBg = Color3.fromRGB(3, 3, 6),
    SidebarBg = Color3.fromRGB(10, 10, 16),
    BoxBg = Color3.fromRGB(8, 8, 12),
    ButtonBg = Color3.fromRGB(16, 16, 24),
    InputBg = Color3.fromRGB(14, 14, 20)
  },
  ["Deep Obsidian"] = {
    Bg = Color3.fromRGB(3, 3, 3),
    HeaderBg = Color3.fromRGB(0, 0, 0),
    SidebarBg = Color3.fromRGB(6, 6, 6),
    BoxBg = Color3.fromRGB(5, 5, 5),
    ButtonBg = Color3.fromRGB(12, 12, 12),
    InputBg = Color3.fromRGB(10, 10, 10)
  },
  ["Slate Steel"] = {
    Bg = Color3.fromRGB(18, 22, 26),
    HeaderBg = Color3.fromRGB(12, 14, 18),
    SidebarBg = Color3.fromRGB(24, 28, 34),
    BoxBg = Color3.fromRGB(16, 20, 24),
    ButtonBg = Color3.fromRGB(28, 34, 40),
    InputBg = Color3.fromRGB(22, 27, 32)
  }
}
local currentThemeName = "Green (Emerald)"
local currentBgThemeName = "Dark (Default)"
local function applyAITheme(aiThemeName)
  local themeData = AIThemes[aiThemeName] or AIThemes["One Protocol (Matcha)"]
  currentThemeName = aiThemeName
  currentWindowTitle = "One Protocol 8.8.26_2beta - Matcha Edition"
  if UIState then
    UIState.ActiveAITheme = aiThemeName
    UIState.ActiveTheme = aiThemeName
  end
  local col = themeData.Accent
  Colors.Accent = col
  Colors.CheckActive = col
  Colors.SelectedBg = Color3.fromRGB(math.floor(col.R * 255 * 0.18), math.floor(col.G * 255 * 0.18), math.floor(col.B * 255 * 0.18))
  Colors.Bg = themeData.Bg
  Colors.HeaderBg = themeData.HeaderBg
  Colors.SidebarBg = themeData.SidebarBg
  Colors.BoxBg = themeData.BoxBg
  Colors.ButtonBg = themeData.ButtonBg
  Colors.InputBg = themeData.InputBg
end
local function applyUITheme(themeName)
  currentThemeName = themeName or "Green (Emerald)"
  if UIState then UIState.ActiveTheme = currentThemeName end
  if currentThemeName == "Rainbow (Dynamic)" then
  else
    local col = UIThemes[currentThemeName] or UIThemes["Green (Emerald)"]
    Colors.Accent = col
    Colors.CheckActive = col
    Colors.SelectedBg = Color3.fromRGB(math.floor(col.R * 255 * 0.18), math.floor(col.G * 255 * 0.18), math.floor(col.B * 255 * 0.18))
  end
end
local function applyUIBgTheme(bgName)
  currentBgThemeName = bgName or "Dark (Default)"
  if UIState then UIState.ActiveBgTheme = currentBgThemeName end
  local bgData = UIBgThemes[currentBgThemeName] or UIBgThemes["Dark (Default)"]
  Colors.Bg = bgData.Bg
  Colors.HeaderBg = bgData.HeaderBg
  Colors.SidebarBg = bgData.SidebarBg
  Colors.BoxBg = bgData.BoxBg
  Colors.ButtonBg = bgData.ButtonBg
  Colors.InputBg = bgData.InputBg
end
local UIState = {
  Visible = true,
  Position = Vector2.new(120, 90),
  ActiveTab = "Info",
  Dragging = false,
  DragOffset = Vector2.new(0, 0),
  LastClick = false,
  FocusedInput = nil,
  ActiveSlider = nil,
  SavedSpeed = 16,
  SavedJump = 50
}
local VK_MAP = {
  [0x30] = "0", [0x31] = "1", [0x32] = "2", [0x33] = "3", [0x34] = "4",
  [0x35] = "5", [0x36] = "6", [0x37] = "7", [0x38] = "8", [0x39] = "9",
  [0x60] = "0", [0x61] = "1", [0x62] = "2", [0x63] = "3", [0x64] = "4",
  [0x65] = "5", [0x66] = "6", [0x67] = "7", [0x68] = "8", [0x69] = "9",
  [0x20] = " ", [0xBE] = ".", [0xBF] = "/", [0xBD] = "-", [0xBB] = "=", [0xBA] = ":"
}
for vk = 0x41, 0x5A do
  VK_MAP[vk] = string.char(vk):lower()
end
local SHIFT_MAP = {
  ["1"] = "!", ["2"] = "@", ["3"] = "#", ["4"] = "$", ["5"] = "%",
  ["6"] = "^", ["7"] = "&", ["8"] = "*", ["9"] = "(", ["0"] = ")",
  ["-"] = "_", ["="] = "+", ["."] = ">", ["/"] = "?", [";"] = ":", [":"] = ":"
}
local Drawings = {}
local function createDraw(type, props)
  local obj = Drawing.new(type)
  obj.Visible = false
  if props then
    for k, v in pairs(props) do
      obj[k] = v
    end
  end
  Drawings[#Drawings + 1] = obj
  return obj
end
local _cachedRoot = nil
local _cachedChar = nil
local _lastRootCheck = 0
local function getRoot()
  local now = os.clock()
  local char = LocalPlayer and LocalPlayer.Character
  if not char and workspace and LocalPlayer and LocalPlayer.Name then
    char = workspace:FindFirstChild(LocalPlayer.Name)
  end
  if not char then
    _cachedRoot = nil
    _cachedChar = nil
    return nil
  end
  if char == _cachedChar and _cachedRoot and _cachedRoot.Parent == char and (now - _lastRootCheck) < 0.5 then
    return _cachedRoot
  end
  _lastRootCheck = now
  _cachedChar = char
  local root = char:FindFirstChild("HumanoidRootPart")
       or char:FindFirstChild("Torso")
       or char:FindFirstChild("UpperTorso")
       or char.PrimaryPart
  if root then
    _cachedRoot = root
    return root
  end
  for _, child in ipairs(char:GetChildren()) do
    if child.Name:find("Torso") or child.Name:find("Root") then
      _cachedRoot = child
      return child
    end
  end
  _cachedRoot = nil
  return nil
end
local function worldToScreen(worldPos)
  local cam = workspace.CurrentCamera
  if not cam then return Vector2.new(0, 0), false end
  local success, p2d, vis = pcall(function()
    local screenPos, onScreen = cam:WorldToScreenPoint(worldPos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
  end)
  if success and p2d then return p2d, (vis == true) end
  if type(WorldToScreen) == "function" then
    local ok, p2dAlt, visAlt = pcall(function() return WorldToScreen(worldPos) end)
    if ok and p2dAlt then return p2dAlt, (visAlt == true) end
  end
  local cf = cam.CFrame
  local fov = cam.FieldOfView or 70
  local vs = cam.ViewportSize or Vector2.new(1920, 1080)
  local relative = nil
  pcall(function() relative = cf:PointToObjectSpace(worldPos) end)
  if not relative then
    pcall(function() relative = cf:Inverse() * worldPos end)
  end
  if not relative then return Vector2.new(0, 0), false end
  if relative.Z >= -0.1 then return Vector2.new(0, 0), false end
  local depth = -relative.Z
  local tanHalfFov = math.tan(math.rad(fov / 2))
  if tanHalfFov == 0 then return Vector2.new(0, 0), false end
  local focal = vs.Y / (2 * tanHalfFov)
  local screenX = (vs.X / 2) + (relative.X / depth) * focal
  local screenY = (vs.Y / 2) - (relative.Y / depth) * focal
  local onScreen = (screenX >= 0 and screenX <= vs.X and screenY >= 0 and screenY <= vs.Y)
  return Vector2.new(screenX, screenY), onScreen
end
local function getPlayerRole(plr)
  if not plr then return "Innocent" end
  local char = plr.Character
  local bp = plr:FindFirstChildOfClass("Backpack")
  local function checkContainer(cont)
    if not cont then return nil end
    for _, item in ipairs(cont:GetChildren()) do
      if item.ClassName == "Tool" then
        local name = item.Name:lower()
        if name:find("knife") or name:find("blade") or item:FindFirstChild("Knife") then
          return "Murderer"
        elseif name:find("gun") or name:find("revolver") or item:FindFirstChild("Gun") then
          return "Sheriff"
        end
      end
    end
    return nil
  end
  local role = checkContainer(char) or checkContainer(bp)
  return role or "Innocent"
end
local SPEED_SAMPLES = 60
local SpeedVisState = {
  Enabled = false,
  TextEnabled = true,
  GraphEnabled = true,
  Samples = SPEED_SAMPLES,
  Delay = 0.03,
  History = {},
  WriteIdx = 0
}
for i = 1, SPEED_SAMPLES do
  SpeedVisState.History[i] = 0
end
local speedTextDraw = createDraw("Text", {
  Size = 28,
  Center = true,
  Outline = true,
  Color = Color3.fromRGB(255, 255, 255),
  Visible = false,
  ZIndex = 100,
  Font = Drawing.Fonts.Plex
})
local speedLinesDraw = {}
for i = 1, SPEED_SAMPLES do
  speedLinesDraw[i] = createDraw("Line", {
    Thickness = 2,
    Color = Color3.fromRGB(0, 170, 255),
    Visible = false,
    ZIndex = 100
  })
end
local lastSpeedPos = nil
local lastSpeedTime = os.clock()
task.spawn(function()
  while true do
    pcall(function()
      local speed = 0
      local root = getRoot()
      local now = os.clock()
      local dt = now - lastSpeedTime
      lastSpeedTime = now
      if root then
        local currentPos = root.Position
        if lastSpeedPos and dt > 0.001 then
          local dx = currentPos.X - lastSpeedPos.X
          local dz = currentPos.Z - lastSpeedPos.Z
          local flatDist = math.sqrt(dx * dx + dz * dz)
          speed = math.floor(flatDist / dt)
        end
        lastSpeedPos = currentPos
      else
        lastSpeedPos = nil
      end
      local idx = (SpeedVisState.WriteIdx % SPEED_SAMPLES) + 1
      SpeedVisState.History[idx] = speed
      SpeedVisState.WriteIdx = SpeedVisState.WriteIdx + 1
      local cam = workspace.CurrentCamera
      local size = cam and cam.ViewportSize or Vector2.new(1280, 720)
      if not SpeedVisState.Enabled then
        if speedTextDraw.Visible then speedTextDraw.Visible = false end
        for i = 1, SPEED_SAMPLES do
          local line = speedLinesDraw[i]
          if line and line.Visible then line.Visible = false end
        end
      else
        local cam = workspace.CurrentCamera
        local size = cam and cam.ViewportSize or Vector2.new(1280, 720)
        local px = size.X - 180
        local py = size.Y - 220
        if SpeedVisState.TextEnabled then
          local speedTxt = tostring(speed) .. " studs/s"
          if speedTextDraw.Text ~= speedTxt then speedTextDraw.Text = speedTxt end
          speedTextDraw.Position = Vector2.new(px + 70, py - 10)
          speedTextDraw.Visible = true
        else
          speedTextDraw.Visible = false
        end
        if SpeedVisState.GraphEnabled then
          local hist = SpeedVisState.History
          local writeIdx = SpeedVisState.WriteIdx
          local maxVal = 0
          for i = 1, SPEED_SAMPLES do
            local v = hist[i]
            if v > maxVal then maxVal = v end
          end
          maxVal = math.max(maxVal, 100)
          local w, h = 140, 60
          local gx, gy = px, py + 30
          local step = w / (SPEED_SAMPLES - 1)
          for i = 1, SPEED_SAMPLES - 1 do
            local readIdx1 = ((writeIdx + i - 1) % SPEED_SAMPLES) + 1
            local readIdx2 = ((writeIdx + i) % SPEED_SAMPLES) + 1
            local x1 = gx + (i - 1) * step
            local x2 = gx + i * step
            local y1 = gy + h - (h * (hist[readIdx1] / maxVal))
            local y2 = gy + h - (h * (hist[readIdx2] / maxVal))
            local line = speedLinesDraw[i]
            if line then
              line.From = Vector2.new(x1, y1)
              line.To = Vector2.new(x2, y2)
              line.Visible = true
            end
          end
        else
          for i = 1, SPEED_SAMPLES do
            local line = speedLinesDraw[i]
            if line and line.Visible then line.Visible = false end
          end
        end
      end
    end)
    task.wait(SpeedVisState.Enabled and (SpeedVisState.Delay or 0.05) or 0.5)
  end
end)
local panicWarningText = nil
local function getPanicWarningText()
  if not panicWarningText then
    pcall(function()
      panicWarningText = Drawing.new("Text")
      panicWarningText.Size = 15
      panicWarningText.Center = true
      panicWarningText.Outline = true
      panicWarningText.OutlineColor = Color3.fromRGB(0, 0, 0)
      panicWarningText.Color = Color3.fromRGB(255, 50, 50)
      panicWarningText.Position = Vector2.new(400, 70)
      panicWarningText.Visible = false
    end)
  end
  return panicWarningText
end
local panicRingLines = {}
local RING_SEGMENTS = 24
local function getPanicRingLines()
  if #panicRingLines == 0 then
    for i = 1, RING_SEGMENTS do
      pcall(function()
        local line = Drawing.new("Line")
        line.Thickness = 2
        line.Color = Color3.fromRGB(0, 255, 0)
        line.Transparency = 1
        line.Visible = false
        panicRingLines[#panicRingLines + 1] = line
      end)
    end
  end
  return panicRingLines
end
local function updatePanicCircle()
  local lines = getPanicRingLines()
  if not (PanicState.Enabled and PanicState.DrawCircle) then
    for _, line in ipairs(lines) do line.Visible = false end
    return
  end
  local root = getRoot()
  if not root then
    for _, line in ipairs(lines) do line.Visible = false end
    return
  end
  pcall(function()
    local feetPos = root.Position - Vector3.new(0, 2.5, 0)
    local radius = PanicState.Distance or 20
    for i = 1, RING_SEGMENTS do
      local a1 = ((i - 1) / RING_SEGMENTS) * math.pi * 2
      local a2 = (i / RING_SEGMENTS) * math.pi * 2
      local p1_3d = feetPos + Vector3.new(math.cos(a1) * radius, 0, math.sin(a1) * radius)
      local p2_3d = feetPos + Vector3.new(math.cos(a2) * radius, 0, math.sin(a2) * radius)
      local s1, on1 = worldToScreen(p1_3d)
      local s2, on2 = worldToScreen(p2_3d)
      local line = lines[i]
      if line then
        if on1 and on2 and s1 and s2 then
          line.From = s1
          line.To = s2
          line.Color = (Colors and Colors.Accent) or Color3.fromRGB(0, 255, 0)
          line.Thickness = 2
          line.Transparency = 1
          line.Visible = true
        else
          line.Visible = false
        end
      end
    end
  end)
end
local panicCircleLastUpdate = 0
RunService.RenderStepped:Connect(function()
  local now = os.clock()
  if (now - panicCircleLastUpdate) < 0.05 then return end
  panicCircleLastUpdate = now
  updatePanicCircle()
end)
pcall(function()
  if LocalPlayer and LocalPlayer.CharacterAdded and type(LocalPlayer.CharacterAdded.Connect) == "function" then
    LocalPlayer.CharacterAdded:Connect(function()
      AntiFlingState.LockHRP = nil
      AntiFlingState.LockHRP2 = 0
    end)
  end
end)
local function zerophysics(part)
  if not part then return end
  pcall(function()
    if part.Address and type(memory_read) == "function" and type(memory_write) == "function" then
      local primitive = memory_read("uintptr_t", part.Address + 0x148)
      if primitive and primitive ~= 0 then
        memory_write("float", primitive + 0xF0, 0)
        memory_write("float", primitive + 0xF4, 0)
        memory_write("float", primitive + 0xF8, 0)
        memory_write("float", primitive + 0xFC, 0)
        memory_write("float", primitive + 0x100, 0)
        memory_write("float", primitive + 0x104, 0)
      end
    end
  end)
end
local function safestate(root)
  if not AntiFlingState.LockHRP then return end
  pcall(function()
    root.CFrame = CFrame.new(AntiFlingState.LockHRP.X, AntiFlingState.LockHRP.Y, AntiFlingState.LockHRP.Z)
    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    zerophysics(root)
  end)
end
local steppedConnection = nil
local lastRageRun = 0
local function disableOtherPlayersCollision()
  pcall(function()
    local myName = LocalPlayer and LocalPlayer.Name
    for _, plr in ipairs(Players:GetPlayers()) do
      if plr.Name ~= myName and plr.Character then
        for _, part in ipairs(plr.Character:GetChildren()) do
          if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
          end
        end
      end
    end
  end)
end
local function restoreOtherPlayersCollision()
  pcall(function()
    local myName = LocalPlayer and LocalPlayer.Name
    for _, plr in ipairs(Players:GetPlayers()) do
      if plr.Name ~= myName and plr.Character then
        for _, part in ipairs(plr.Character:GetChildren()) do
          if part:IsA("BasePart") then
            part.CanCollide = true
          end
        end
      end
    end
  end)
end
local function setRageAntiFling(state)
  AntiFlingState.RageEnabled = state
  if state then
    if not steppedConnection then
      steppedConnection = RunService.Stepped:Connect(function()
        if not AntiFlingState.RageEnabled then return end
        local now = os.clock()
        if (now - lastRageRun) >= 0.1 then
          lastRageRun = now
          task.spawn(disableOtherPlayersCollision)
        end
      end)
    end
  else
    if steppedConnection then
      pcall(function() steppedConnection:Disconnect() end)
      steppedConnection = nil
    end
    task.spawn(restoreOtherPlayersCollision)
  end
end
local function setLegitAntiFling(state)
  AntiFlingState.LegitEnabled = state
  if not state then
    AntiFlingState.LockHRP = nil
    AntiFlingState.LockHRP2 = 0
  end
end
local farmFreezePos = nil
local function lockFarmFreeze()
  if AutoFarmState and AutoFarmState.Enabled and farmFreezePos then
    pcall(function()
      local char = LocalPlayer and LocalPlayer.Character
      if char then
        for _, part in ipairs(char:GetDescendants()) do
          if part:IsA("BasePart") then
            part.CanCollide = false
          end
        end
        local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
        if hrp and farmFreezePos then
          hrp.CFrame = CFrame.new(farmFreezePos.X, farmFreezePos.Y, farmFreezePos.Z)
          hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
          hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
      end
    end)
  end
end
local NoclipState = {
  Enabled = false
}
local isResettingCharacter = false
local function applyNoclipToCharacter(char)
  if not char or isResettingCharacter then return end
  pcall(function()
    for _, part in ipairs(char:GetDescendants()) do
      if part:IsA("BasePart") then
        part.CanCollide = false
        pcall(function() part.CanQuery = false end)
      end
    end
  end)
end
local function handleNoclipStepped()
  if isResettingCharacter then return end
  local isNoclipActive = (NoclipState and NoclipState.Enabled)
    or (AutoFarmState and AutoFarmState.Enabled)
    or (AutoFarmState and AutoFarmState.NoclipFarm)
  if isNoclipActive then
    local char = LocalPlayer and LocalPlayer.Character
    if char then
      applyNoclipToCharacter(char)
    end
  end
end
local _noclipLastRun = 0
RunService.Stepped:Connect(function()
  if isResettingCharacter then return end
  local now = os.clock()
  if (now - _noclipLastRun) < 0.033 then
    if AutoFarmState and AutoFarmState.Enabled and farmFreezePos then
      local char = LocalPlayer and LocalPlayer.Character
      if char then
        local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
        if hrp then
          hrp.CFrame = CFrame.new(farmFreezePos.X, farmFreezePos.Y, farmFreezePos.Z)
          hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
          hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
      end
    end
    return
  end
  _noclipLastRun = now
  local char = LocalPlayer and LocalPlayer.Character
  if not char then return end
  local isNoclip = (NoclipState and NoclipState.Enabled)
    or (AutoFarmState and AutoFarmState.Enabled)
    or (AutoFarmState and AutoFarmState.NoclipFarm)
  if isNoclip then
    for _, p in ipairs(char:GetChildren()) do
      if p:IsA("BasePart") and p.CanCollide then
        p.CanCollide = false
      end
    end
  end
  if AutoFarmState and AutoFarmState.Enabled and farmFreezePos then
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    if hrp then
      hrp.CFrame = CFrame.new(farmFreezePos.X, farmFreezePos.Y, farmFreezePos.Z)
      hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
      hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
  end
end)
if LocalPlayer then
  pcall(function()
    if LocalPlayer.CharacterAdded and type(LocalPlayer.CharacterAdded.Connect) == "function" then
      LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(0.1)
        local isNoclipActive = (NoclipState and NoclipState.Enabled)
          or (AutoFarmState and AutoFarmState.Enabled)
          or (AutoFarmState and AutoFarmState.NoclipFarm)
        if isNoclipActive then
          applyNoclipToCharacter(newChar)
        end
      end)
    end
  end)
end
local activeTargetCoinPart = nil
local function updateWatchCoinCamera()
  if AutoFarmState and AutoFarmState.Enabled and AutoFarmState.WatchCoinCamera and activeTargetCoinPart and activeTargetCoinPart.Parent then
    pcall(function()
      local cam = workspace.CurrentCamera
      if cam then
        local cPos = activeTargetCoinPart.Position
        cam.CFrame = CFrame.new(cPos + Vector3.new(0, 4, 6), cPos)
      end
    end)
  end
end
local function isValid(object) return object and object.Parent ~= nil end
local function isAlive()
  local plr = LocalPlayer
  return plr and plr:GetAttribute("Alive")
end
local function forceResetCharacter(keepEnabled)
  isResettingCharacter = true
  if not keepEnabled and AutoFarmState then AutoFarmState.Enabled = false end
  firstpos = nil
  firstcframe = nil
  farmFreezePos = nil
  activeTargetCoinPart = nil
  pcall(function()
    local plr = LocalPlayer
    local char = plr and plr.Character
    if char then
      local hum = char:FindFirstChildOfClass("Humanoid") or char:FindFirstChild("Humanoid")
      if hum then
        if hum.Address and type(memory_write) == "function" then
          pcall(function() memory_write("float", hum.Address + 0x18C + 8, 0.0) end)
        end
        pcall(function() hum.Health = 0 end)
      end
      for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
          part.CanCollide = false
        end
      end
      local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
      if hrp then
        hrp.CFrame = CFrame.new(0, -300, 0)
        hrp.Velocity = Vector3.new(0, -100, 0)
        pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0, -100, 0) end)
      end
      pcall(function() char:BreakJoints() end)
    end
  end)
  task.delay(1.5, function()
    isResettingCharacter = false
  end)
end
local function enableZeroGravity(hrp)
  if not hrp then return end
  pcall(function()
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
  end)
end
local function disableZeroGravity(hrp)
end
local function enableTPose(char)
  if not char then return end
  pcall(function()
    local animScript = char:FindFirstChild("Animate")
    if animScript then
      animScript.Disabled = true
    end
    local hum = char:FindFirstChildOfClass("Humanoid") or char:FindFirstChild("Humanoid")
    if hum then
      local animator = hum:FindFirstChildOfClass("Animator") or hum:FindFirstChild("Animator")
      if animator and type(animator.GetPlayingAnimationTracks) == "function" then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
          pcall(function() track:Stop(0) end)
        end
      end
      if type(hum.GetPlayingAnimationTracks) == "function" then
        for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
          pcall(function() track:Stop(0) end)
        end
      end
    end
  end)
end
local function disableTPose(char)
  if not char then return end
  pcall(function()
    local animScript = char:FindFirstChild("Animate")
    if animScript then
      animScript.Disabled = false
    end
  end)
end
task.spawn(function()
  while true do
    if QuickResetKeybindEnabled then
      pcall(function()
        local active = true
        if type(isrbxactive) == "function" then
          active = isrbxactive()
        end
        if active and type(iskeypressed) == "function" and (iskeypressed(0x50) or iskeypressed(0x52)) then
          forceResetCharacter()
          task.wait(0.25)
        end
      end)
    end
    task.wait(0.05)
  end
end)
local AntiAFKState = {
  Enabled = false,
  ShowOverlay = true,
  Interval = 60,
  KeybindEnabled = true
}
local VK_RCONTROL = 0xA3
local PULSE_SECONDS = 0.02
local MOVE_KEYS = { 0x57, 0x41, 0x53, 0x44 }
local antiAfkOverlay = nil
local antiAfkFading = false
local function getViewportSize()
  local ok, size = pcall(function()
    return workspace.CurrentCamera.ViewportSize
  end)
  if ok and size then return size end
  return Vector2.new(1920, 1080)
end
local function createAntiAfkOverlay()
  pcall(function()
    local text = Drawing.new("Text")
    text.Visible = false
    text.Text = "Anti-AFK is ON"
    text.Color = Color3.fromHSV(0, 1, 1)
    text.Center = true
    text.Outline = true
    text.Size = 32
    text.ZIndex = 1000
    local group = { Text = text, Visible = false }
    function group:SetVisible(v)
      self.Visible = (v == true)
      if self.Text then self.Text.Visible = self.Visible end
    end
    function group:SetTransparency(v)
      if self.Text then self.Text.Transparency = math.clamp(1 - v, 0, 1) end
    end
    function group:Layout()
      local vp = getViewportSize()
      if self.Text then self.Text.Position = Vector2.new(vp.X / 2, vp.Y / 2 - 120) end
    end
    function group:Remove()
      pcall(function() if self.Text then self.Text:Remove() end end)
    end
    antiAfkOverlay = group
  end)
end
local function showAntiAfkOverlay()
  if not AntiAFKState.ShowOverlay then return end
  antiAfkFading = false
  if not antiAfkOverlay then createAntiAfkOverlay() end
  if not antiAfkOverlay then return end
  antiAfkOverlay:Layout()
  antiAfkOverlay:SetTransparency(0)
  antiAfkOverlay:SetVisible(true)
  task.spawn(function()
    local duration = 0.45
    local started = os.clock()
    while AntiAFKState.Enabled and (os.clock() - started < duration) do
      local alpha = (os.clock() - started) / duration
      if antiAfkOverlay then antiAfkOverlay:SetTransparency(alpha) end
      task.wait(0.016)
    end
    if AntiAFKState.Enabled and antiAfkOverlay then
      antiAfkOverlay:SetTransparency(1)
    end
  end)
end
local function fadeOutAntiAfkOverlay()
  if not antiAfkOverlay or antiAfkFading then return end
  antiAfkFading = true
  task.spawn(function()
    local duration = 0.45
    local started = os.clock()
    while os.clock() - started < duration do
      local alpha = 1 - ((os.clock() - started) / duration)
      if antiAfkOverlay then antiAfkOverlay:SetTransparency(alpha) end
      task.wait(0.016)
    end
    if antiAfkOverlay then
      antiAfkOverlay:SetTransparency(0)
      antiAfkOverlay:SetVisible(false)
    end
    antiAfkFading = false
  end)
end
local function setAntiAFKEnabled(value)
  AntiAFKState.Enabled = (value == true)
  if AntiAFKState.Enabled then
    showAntiAfkOverlay()
  else
    fadeOutAntiAfkOverlay()
  end
end
pcall(function()
  local vu = game:GetService("VirtualUser")
  local plr = game:GetService("Players").LocalPlayer
  if plr and plr.Idled and type(plr.Idled.Connect) == "function" then
    plr.Idled:Connect(function()
      if AntiAFKState.Enabled then
        pcall(function()
          if vu then
            vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
          end
        end)
      end
    end)
  end
end)
task.spawn(function()
  local wasDown = false
  while true do
    if AntiAFKState.KeybindEnabled then
      pcall(function()
        local active = true
        if type(isrbxactive) == "function" then active = isrbxactive() end
        local down = active and (type(iskeypressed) == "function" and iskeypressed(VK_RCONTROL))
        if down and not wasDown then
          setAntiAFKEnabled(not AntiAFKState.Enabled)
        end
        wasDown = down
      end)
    end
    task.wait(0.03)
  end
end)
task.spawn(function()
  while true do
    if AntiAFKState.Enabled then
      pcall(function()
        if antiAfkOverlay and antiAfkOverlay.Visible then antiAfkOverlay:Layout() end
        local vk = MOVE_KEYS[math.random(1, #MOVE_KEYS)]
        if type(keypress) == "function" and type(keyrelease) == "function" then
          keypress(vk)
          task.wait(PULSE_SECONDS)
          keyrelease(vk)
        end
      end)
      local waitTime = math.clamp(AntiAFKState.Interval or 60, 5, 300)
      local elapsed = 0
      while elapsed < waitTime and AntiAFKState.Enabled do
        task.wait(1.0)
        elapsed = elapsed + 1.0
      end
    else
      task.wait(0.2)
    end
  end
end)
RunService.RenderStepped:Connect(function()
  if antiAfkOverlay and antiAfkOverlay.Text and antiAfkOverlay.Visible then
    pcall(function()
      antiAfkOverlay.Text.Color = Color3.fromHSV((os.clock() * 0.25) % 1, 1, 1)
    end)
  end
end)
local ESPState = {
  Enabled = false,
  Boxes = true,
  Names = true,
  Distance = true,
  ShowMurderer = true,
  ShowSheriff = true,
  ShowInnocent = true,
  GunDrop = true,
  Coins = true,
  MaxDistance = 500,
  MurdererColor = Color3.fromRGB(255, 50, 50),
  SheriffColor = Color3.fromRGB(50, 100, 255),
  InnocentColor = Color3.fromRGB(50, 255, 50),
  GunDropColor = Color3.fromRGB(255, 200, 0),
  CoinColor = Color3.fromRGB(255, 220, 0),
  GreyColor = Color3.fromRGB(180, 180, 180)
}
local ESP_POOL = 32
local GUN_POOL = 8
local COIN_POOL = 64
local espPool = {}
local gunPool = {}
local coinPool = {}
local espTargets = {}
local allPlayersCache = {}
local gunDropTargets = {}
local testGunDropTargets = {}
local coinDropTargets = {}
local testCoinDropTargets = {}
local coinTargets = {}
local testCoinTargets = {}
local murdLabel, sheriffLabel, gunDropLabel = nil, nil, nil
local espFoundMurd, espFoundSheriff = "Searching...", "Searching..."
for i = 1, ESP_POOL do
  local top = Drawing.new("Line"); top.Thickness = 1; top.Visible = false
  local bot = Drawing.new("Line"); bot.Thickness = 1; bot.Visible = false
  local left = Drawing.new("Line"); left.Thickness = 1; left.Visible = false
  local right = Drawing.new("Line"); right.Thickness = 1; right.Visible = false
  local name = Drawing.new("Text"); name.Size = 13; name.Center = true; name.Outline = true; name.Visible = false
  local dist = Drawing.new("Text"); dist.Size = 13; dist.Center = true; dist.Outline = true; dist.Visible = false; dist.Color = ESPState.GreyColor
  pcall(function() name.Font = 1 end)
  pcall(function() dist.Font = 1 end)
  espPool[i] = { top = top, bot = bot, left = left, right = right, name = name, dist = dist }
end
for i = 1, GUN_POOL do
  local top = Drawing.new("Line"); top.Thickness = 1; top.Color = ESPState.GunDropColor; top.Visible = false
  local bot = Drawing.new("Line"); bot.Thickness = 1; bot.Color = ESPState.GunDropColor; bot.Visible = false
  local left = Drawing.new("Line"); left.Thickness = 1; left.Color = ESPState.GunDropColor; left.Visible = false
  local right = Drawing.new("Line"); right.Thickness = 1; right.Color = ESPState.GunDropColor; right.Visible = false
  local lbl = Drawing.new("Text"); lbl.Size = 13; lbl.Center = true; lbl.Outline = true; lbl.Visible = false; lbl.Color = ESPState.GunDropColor; lbl.Text = "GUN DROP"
  pcall(function() lbl.Font = 1 end)
  gunPool[i] = { top = top, bot = bot, left = left, right = right, lbl = lbl }
end
for i = 1, COIN_POOL do
  local top = Drawing.new("Line"); top.Thickness = 1; top.Color = ESPState.CoinColor; top.Visible = false
  local bot = Drawing.new("Line"); bot.Thickness = 1; bot.Color = ESPState.CoinColor; bot.Visible = false
  local left = Drawing.new("Line"); left.Thickness = 1; left.Color = ESPState.CoinColor; left.Visible = false
  local right = Drawing.new("Line"); right.Thickness = 1; right.Color = ESPState.CoinColor; right.Visible = false
  local lbl = Drawing.new("Text"); lbl.Size = 12; lbl.Center = true; lbl.Outline = true; lbl.Visible = false; lbl.Color = ESPState.CoinColor; lbl.Text = "COIN"
  pcall(function() lbl.Font = 1 end)
  coinPool[i] = { top = top, bot = bot, left = left, right = right, lbl = lbl }
end
local function getRole(plr)
  local role = getPlayerRole(plr)
  local col = ESPState.InnocentColor
  if role == "Murderer" then
    col = ESPState.MurdererColor
  elseif role == "Sheriff" then
    col = ESPState.SheriffColor
  end
  return col, role
end
local espCollectorRunning = true
local gunScanCounter = 0
task.spawn(function()
  while espCollectorRunning do
    pcall(function()
      local me = LocalPlayer and LocalPlayer.Name or ""
      local out = {}
      local allPlrs = {}
      local fMurd, fSheriff = "Searching...", "Searching..."
      for _, plr in ipairs(Players:GetPlayers()) do
        if plr and plr.Name ~= me then
          local chr = plr.Character
          if chr then
            local root = chr:FindFirstChild("HumanoidRootPart")
            local head = chr:FindFirstChild("Head") or root
            if root then
              local col, role = getRole(plr)
              if role == "Murderer" then fMurd = plr.Name end
              if role == "Sheriff" then fSheriff = plr.Name end
              allPlrs[#allPlrs + 1] = {
                name = plr.Name,
                role = role,
                col = col,
                head = head,
                root = root
              }
              if ESPState.Enabled then
                local showRole = (role == "Murderer" and ESPState.ShowMurderer)
                       or (role == "Sheriff" and ESPState.ShowSheriff)
                       or (role == "Innocent" and ESPState.ShowInnocent)
                if showRole then
                  out[#out + 1] = allPlrs[#allPlrs]
                end
              end
            end
          end
        end
      end
      espFoundMurd = fMurd
      espFoundSheriff = fSheriff
      espTargets = ESPState.Enabled and out or {}
      allPlayersCache = allPlrs
      gunScanCounter = gunScanCounter + 1
      if gunScanCounter >= 4 then
        gunScanCounter = 0
        local gout = {}
        pcall(function()
          local gObj = workspace:FindFirstChild("GunDrop", true) or workspace:FindFirstChild("WeaponDrop", true)
          if gObj and gObj.Parent then
            gout[#gout + 1] = gObj
          end
        end)
        for i = 1, #testGunDropTargets do
          local tpart = testGunDropTargets[i]
          if tpart and tpart.Parent then
            gout[#gout + 1] = tpart
          end
        end
        gunDropTargets = gout
        local cout = {}
        pcall(function()
          local container = getCoinContainer()
          if container and container.GetChildren then
            local children = container:GetChildren()
            for i = 1, #children do
              local obj = children[i]
              if obj and obj.Parent then
                cout[#cout + 1] = obj
              end
            end
          end
        end)
        for i = 1, #testCoinDropTargets do
          local tpart = testCoinDropTargets[i]
          if tpart and tpart.Parent then
            cout[#cout + 1] = tpart
          end
        end
        coinDropTargets = cout
        coinTargets = cout
      end
    end)
    task.wait(0.2)
  end
end)
local espWasActive = nil
RunService.RenderStepped:Connect(function(dt)
  pcall(function()
    if not ESPState.Enabled then
      if espWasActive ~= false then
        espWasActive = false
        for i = 1, ESP_POOL do
          local s = espPool[i]
          s.top.Visible = false; s.bot.Visible = false; s.left.Visible = false; s.right.Visible = false
          s.name.Visible = false; s.dist.Visible = false
        end
        for i = 1, GUN_POOL do
          local g = gunPool[i]
          g.top.Visible = false; g.bot.Visible = false; g.left.Visible = false; g.right.Visible = false
          g.lbl.Visible = false
        end
        for i = 1, COIN_POOL do
          local c = coinPool[i]
          c.top.Visible = false; c.bot.Visible = false; c.left.Visible = false; c.right.Visible = false
          c.lbl.Visible = false
        end
      end
      return
    end
    espWasActive = true
    local cam = workspace.CurrentCamera
    local camPos = cam and cam.CFrame and cam.CFrame.Position
    local list = espTargets
    local n = 0
    local maxDist = ESPState.MaxDistance or 500
    for i = 1, #list do
      if n >= ESP_POOL then break end
      local t = list[i]
      local headRef = t.head
      local rootRef = t.root
      if headRef and rootRef then
        local distToCam = camPos and (camPos - rootRef.Position).Magnitude or 0
        if distToCam <= maxDist then
          local topPos = headRef.Position + Vector3.new(0, 0.7, 0)
          local botPos = rootRef.Position - Vector3.new(0, 3.2, 0)
          local top2d, v1 = worldToScreen(topPos)
          local bot2d, v2 = worldToScreen(botPos)
          if v1 and v2 then
            n = n + 1
            local s = espPool[n]
            local h = bot2d.Y - top2d.Y
            local w = math.abs(h * 0.5)
            local cx = top2d.X
            local L = cx - w * 0.5
            local R = cx + w * 0.5
            local T = top2d.Y
            local B = bot2d.Y
            s.top.From = Vector2.new(L, T); s.top.To = Vector2.new(R, T)
            s.top.Color = t.col; s.top.Visible = ESPState.Boxes
            s.bot.From = Vector2.new(L, B); s.bot.To = Vector2.new(R, B)
            s.bot.Color = t.col; s.bot.Visible = ESPState.Boxes
            s.left.From = Vector2.new(L, T); s.left.To = Vector2.new(L, B)
            s.left.Color = t.col; s.left.Visible = ESPState.Boxes
            s.right.From = Vector2.new(R, T); s.right.To = Vector2.new(R, B)
            s.right.Color = t.col; s.right.Visible = ESPState.Boxes
            s.name.Color = t.col
            s.name.Text = t.role .. " | " .. t.name
            s.name.Position = Vector2.new(cx, T - 16)
            s.name.Visible = ESPState.Names
            s.dist.Text = math.floor(distToCam) .. "m"
            s.dist.Position = Vector2.new(cx, B + 3)
            s.dist.Visible = ESPState.Distance
          end
        end
      end
    end
    for i = n + 1, ESP_POOL do
      local s = espPool[i]
      s.top.Visible = false; s.bot.Visible = false; s.left.Visible = false; s.right.Visible = false
      s.name.Visible = false; s.dist.Visible = false
    end
    local gn = 0
    if ESPState.GunDrop then
      local glist = gunDropTargets
      for i = 1, #glist do
        if gn >= GUN_POOL then break end
        local part = glist[i]
        if part and part.Parent then
          local distToCam = camPos and (camPos - part.Position).Magnitude or 0
          if distToCam <= maxDist then
            local p2d, vis = worldToScreen(part.Position)
            if vis then
              gn = gn + 1
              local g = gunPool[gn]
              local sz = 14
              g.top.From = Vector2.new(p2d.X - sz, p2d.Y - sz); g.top.To = Vector2.new(p2d.X + sz, p2d.Y - sz); g.top.Visible = ESPState.Boxes
              g.bot.From = Vector2.new(p2d.X - sz, p2d.Y + sz); g.bot.To = Vector2.new(p2d.X + sz, p2d.Y + sz); g.bot.Visible = ESPState.Boxes
              g.left.From = Vector2.new(p2d.X - sz, p2d.Y - sz); g.left.To = Vector2.new(p2d.X - sz, p2d.Y + sz); g.left.Visible = ESPState.Boxes
              g.right.From = Vector2.new(p2d.X + sz, p2d.Y - sz); g.right.To = Vector2.new(p2d.X + sz, p2d.Y + sz); g.right.Visible = ESPState.Boxes
              g.lbl.Position = Vector2.new(p2d.X, p2d.Y - sz - 14); g.lbl.Visible = ESPState.Names
            end
          end
        end
      end
    end
    for i = gn + 1, GUN_POOL do
      local g = gunPool[i]
      g.top.Visible = false; g.bot.Visible = false; g.left.Visible = false; g.right.Visible = false
      g.lbl.Visible = false
    end
    local cn = 0
    if ESPState.Coins then
      local clist = coinTargets or {}
      for i = 1, #clist do
        if cn >= COIN_POOL then break end
        local part = clist[i]
        local pos = getCoinPos(part)
        if pos then
          local distToCam = camPos and (camPos - pos).Magnitude or 0
          if distToCam <= maxDist then
            local p2d, vis = worldToScreen(pos)
            if vis then
              cn = cn + 1
              local c = coinPool[cn]
              local sz = 10
              local coinCol = ESPState.CoinColor or Color3.fromRGB(255, 220, 0)
              c.top.From = Vector2.new(p2d.X - sz, p2d.Y - sz); c.top.To = Vector2.new(p2d.X + sz, p2d.Y - sz); c.top.Color = coinCol; c.top.Visible = true
              c.bot.From = Vector2.new(p2d.X - sz, p2d.Y + sz); c.bot.To = Vector2.new(p2d.X + sz, p2d.Y + sz); c.bot.Color = coinCol; c.bot.Visible = true
              c.left.From = Vector2.new(p2d.X - sz, p2d.Y - sz); c.left.To = Vector2.new(p2d.X - sz, p2d.Y + sz); c.left.Color = coinCol; c.left.Visible = true
              c.right.From = Vector2.new(p2d.X + sz, p2d.Y - sz); c.right.To = Vector2.new(p2d.X + sz, p2d.Y + sz); c.right.Color = coinCol; c.right.Visible = true
              c.lbl.Text = "COIN"
              c.lbl.Color = coinCol
              c.lbl.Position = Vector2.new(p2d.X, p2d.Y - sz - 14)
              c.lbl.Visible = true
            end
          end
        end
      end
    end
    for i = cn + 1, COIN_POOL do
      local c = coinPool[i]
      c.top.Visible = false; c.bot.Visible = false; c.left.Visible = false; c.right.Visible = false
      c.lbl.Visible = false
    end
    pcall(function()
      local newMurdTxt = "- Murderer: " .. tostring(espFoundMurd)
      local newSheriffTxt = "- Sheriff: " .. tostring(espFoundSheriff)
      local newGunTxt = "- Gun Dropped: " .. (#gunDropTargets > 0 and "YES" or "NO")
      if murdLabel and murdLabel.Text ~= newMurdTxt then murdLabel:SetText(newMurdTxt) end
      if sheriffLabel and sheriffLabel.Text ~= newSheriffTxt then sheriffLabel:SetText(newSheriffTxt) end
      if gunDropLabel and gunDropLabel.Text ~= newGunTxt then gunDropLabel:SetText(newGunTxt) end
    end)
  end)
end)
local panicLastCheck = 0
RunService.Heartbeat:Connect(function()
  if PanicState.Enabled then
    local nowPanic = os.clock()
    if (nowPanic - panicLastCheck) < 0.2 then return end
    panicLastCheck = nowPanic
    local ok, err = pcall(function()
      local root = getRoot()
      local warnTxt = getPanicWarningText()
      if not root then return end
      local nearbyPlrs = {}
      local now = os.clock()
      local checkPos = root.Position
      local checkThreshold = PanicState.Distance or 35
      local targets = allPlayersCache or {}
      for i = 1, #targets do
        local t = targets[i]
        local otherRoot = t.root
        if otherRoot and otherRoot.Parent then
          local otherPos = otherRoot.Position
          local dy = math.abs(otherPos.Y - checkPos.Y)
          if dy <= 45 then
            local dx = otherPos.X - checkPos.X
            local dz = otherPos.Z - checkPos.Z
            local flatDist = math.sqrt(dx * dx + dz * dz)
            if flatDist <= checkThreshold then
              local role = t.role or "Innocent"
              local tf = PanicState.TargetFilter or "All Players"
              local shouldTrigger = (tf == "All Players")
                       or (tf == "Murderer Only" and role == "Murderer")
                       or (tf == "Murderer & Sheriff" and (role == "Murderer" or role == "Sheriff"))
              if shouldTrigger then
                nearbyPlrs[#nearbyPlrs + 1] = { Player = { Name = t.name }, Root = otherRoot, Dist = flatDist }
              end
            end
          end
        end
      end
      if PanicState.Mode == "Speed Surge (+50%)" or PanicState.Mode == "Speed Surge" or PanicState.Mode == "TPWalk" then
        if #nearbyPlrs > 0 then
          if not PanicState.IsSpeedBoosted then
            PanicState.IsSpeedBoosted = true
            local targetPlr = nearbyPlrs[1]
            local pName = targetPlr and targetPlr.Player and targetPlr.Player.Name or "Player"
            local pDist = targetPlr and math.floor(targetPlr.Dist) or 0
          end
          pcall(function()
            if root then
              local moveVector = Vector3.new(0, 0, 0)
              local isW = checkKey(0x57)
              local isS = checkKey(0x53)
              local isA = checkKey(0x41)
              local isD = checkKey(0x44)
              local cam = workspace.CurrentCamera
              if cam then
                local look = cam.CFrame.LookVector
                local right = cam.CFrame.RightVector
                local flatLook = Vector3.new(look.X, 0, look.Z)
                local flatRight = Vector3.new(right.X, 0, right.Z)
                if flatLook.Magnitude > 0.01 then flatLook = flatLook.Unit end
                if flatRight.Magnitude > 0.01 then flatRight = flatRight.Unit end
                if isW then moveVector = moveVector + flatLook end
                if isS then moveVector = moveVector - flatLook end
                if isA then moveVector = moveVector - flatRight end
                if isD then moveVector = moveVector + flatRight end
              end
              if moveVector.Magnitude < 0.01 and root.AssemblyLinearVelocity then
                local vel = root.AssemblyLinearVelocity
                local flatVel = Vector3.new(vel.X, 0, vel.Z)
                if flatVel.Magnitude > 0.5 then moveVector = flatVel end
              end
              if moveVector.Magnitude > 0.01 then
                local dir = moveVector.Unit
                local newPos = root.Position + (dir * 1.0)
                local setSuccess = false
                if CFrame.lookAt then
                  pcall(function()
                    root.CFrame = CFrame.lookAt(newPos, newPos + dir)
                    setSuccess = true
                  end)
                end
                if not setSuccess then
                  local angle = math.atan2(-dir.X, -dir.Z)
                  root.CFrame = CFrame.new(newPos.X, newPos.Y, newPos.Z) * CFrame.Angles(0, angle, 0)
                end
              end
            end
          end)
        else
          if PanicState.IsSpeedBoosted then
            PanicState.IsSpeedBoosted = false
          end
        end
      elseif PanicState.Mode == "Float (Hover)" or PanicState.Mode == "Float" then
        if #nearbyPlrs > 0 then
          PanicState.LastClear = now
          if not PanicState.IsUnderMap then
            PanicState.IsUnderMap = true
            PanicState.EntryPos = root.Position
            PanicState.SurfaceY = root.Position.Y
            PanicState.EnterTime = now
          end
          local targetY = (PanicState.SurfaceY or root.Position.Y) + 20
          root.CFrame = CFrame.new(root.Position.X, targetY, root.Position.Z)
          pcall(function()
            local v = root.AssemblyLinearVelocity
            root.AssemblyLinearVelocity = Vector3.new(v.X, 0, v.Z)
            local char = LocalPlayer and LocalPlayer.Character
            if char then
              for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
              end
            end
          end)
        else
          if PanicState.IsUnderMap and (now - (PanicState.LastClear or 0)) >= 0.3 then
            PanicState.IsUnderMap = false
            pcall(function()
              local char = LocalPlayer and LocalPlayer.Character
              if char then
                for _, part in ipairs(char:GetChildren()) do
                  if part:IsA("BasePart") then part.CanCollide = true end
                end
              end
            end)
            root.CFrame = CFrame.new(root.Position.X, (PanicState.SurfaceY or root.Position.Y), root.Position.Z)
            PanicState.SurfaceY = nil
            PanicState.EntryPos = nil
          end
        end
      elseif PanicState.Mode == "Teleport" then
        if PanicState.IsUnderMap and PanicState.EntryPos then
          root.CFrame = CFrame.new(PanicState.EntryPos.X, (PanicState.SurfaceY or PanicState.EntryPos.Y) + 2, PanicState.EntryPos.Z)
          PanicState.IsUnderMap = false
          PanicState.SurfaceY = nil
          PanicState.EntryPos = nil
        end
        if #nearbyPlrs > 0 and (now - (PanicState.LastEvade or 0)) >= 0.35 then
          PanicState.LastEvade = now
          local closest = nearbyPlrs[1]
          local otherRoot = closest.Root
          local dir = (root.Position - otherRoot.Position)
          local flatDir = Vector3.new(dir.X, 0, dir.Z)
          if flatDir.Magnitude < 0.1 then flatDir = Vector3.new(1, 0, 0) end
          flatDir = flatDir.Unit
          local pushDist = (PanicState.Distance - closest.Dist) + 10
          local safePos = root.Position + (flatDir * pushDist)
          root.CFrame = CFrame.new(safePos.X, root.Position.Y, safePos.Z)
        end
      elseif PanicState.Mode == "Warning" then
        if PanicState.IsUnderMap and PanicState.EntryPos then
          root.CFrame = CFrame.new(PanicState.EntryPos.X, (PanicState.SurfaceY or PanicState.EntryPos.Y) + 2, PanicState.EntryPos.Z)
          PanicState.IsUnderMap = false
          PanicState.SurfaceY = nil
          PanicState.EntryPos = nil
        end
      end
      if warnTxt then
        if #nearbyPlrs > 0 then
          local cam = workspace.CurrentCamera
          if cam and cam.ViewportSize then
            warnTxt.Position = Vector2.new(cam.ViewportSize.X / 2, 70)
          end
          warnTxt.Text = "WARNING: " .. tostring(#nearbyPlrs) .. " Player(s) Nearby!"
          warnTxt.Color = Color3.fromRGB(255, 50, 50)
          warnTxt.Visible = true
        else
          warnTxt.Visible = false
        end
      end
    end)
    if not ok then
    end
  else
    if panicWarningText then panicWarningText.Visible = false end
  end
end)
RunService.Heartbeat:Connect(function()
  if not AntiFlingState.LegitEnabled then
    AntiFlingState.LockHRP = nil
    AntiFlingState.LockHRP2 = 0
    return
  end
  local root = getRoot()
  if not root then
    AntiFlingState.LockHRP = nil
    return
  end
  local now = os.clock()
  local speed = 0
  pcall(function()
    speed = root.AssemblyLinearVelocity.Magnitude
  end)
  if not AntiFlingState.LockHRP then
    AntiFlingState.LockHRP = root.Position
  end
  if now >= AntiFlingState.LockHRP2 and speed <= AntiFlingState.VelocityCap then
    AntiFlingState.LockHRP = root.Position
  end
  if speed > AntiFlingState.VelocityCap then
    AntiFlingState.LockHRP2 = now + AntiFlingState.LockTime
  end
  if now < AntiFlingState.LockHRP2 then
    safestate(root)
  end
end)
local spinAngle = 0
local AutoRespawnFakeCoins = false
local visitedCoinsMap = {}
local initialMapY = nil
local _lastFullGC = 0
task.spawn(function()
  while true do
    task.wait(5.0)
    pcall(function()
      local now = os.clock()
      local cleaned = 0
      for key, expireTime in pairs(visitedCoinsMap) do
        if type(expireTime) == "number" and now >= expireTime then
          visitedCoinsMap[key] = nil
          cleaned = cleaned + 1
        elseif type(key) == "userdata" then
          local parentOk, hasParent = pcall(function() return key.Parent end)
          if not parentOk or not hasParent then
            visitedCoinsMap[key] = nil
            cleaned = cleaned + 1
          end
        end
      end
    end)
    local nowGC = os.clock()
    if (nowGC - _lastFullGC) >= 10.0 then
      _lastFullGC = nowGC
      pcall(function()
        if type(collectgarbage) == "function" then
          collectgarbage("step", 200)
        end
      end)
    end
  end
end)
local AutoFarmState = {
  Enabled = false,
  Method = "Normal",
  FacingMode = "Instant Lock",
  FullBagAction = "Reset / Die",
  Speed = 25,
  UndermapSpeed = 25,
  TeleportCooldown = 0.3,
  Undermap2Speed = 20,
  Undermap2Freeze = 0.49,
  MaxCoins = 50,
  UndermapOffset = 6,
  PickupOffset = 3,
  Undermap2Offset = 4.0,
  CoinDelay = 0.5,
  EvadePlayers = false,
  EvadeRadius = 25,
  NoclipFarm = false,
  CanTween = true,
  IsFirst = true,
  IsFirstCoinOfRound = true,
  SafeAvoidEnabled = false,
  SafeAvoidTarget = "Murderer Only",
  SafeAvoidRadius = 20,
  SafeMidFlightEvade = true
}
local function getPlayerRole(plr)
  if not plr then return "Innocent" end
  local detectedRole = "Innocent"
  pcall(function()
    local char = plr.Character
    local bp = plr:FindFirstChildOfClass("Backpack") or plr:FindFirstChild("Backpack")
    local function scanTool(tool)
      if not tool or not tool:IsA("Tool") then return nil end
      if tool:FindFirstChild("KnifeServer") or tool:FindFirstChild("KnifeScript") or tool:FindFirstChild("Stab") or tool:FindFirstChild("KnifeClient") then
        return "Murderer"
      end
      if tool:FindFirstChild("GunServer") or tool:FindFirstChild("GunScript") or tool:FindFirstChild("Shoot") or tool:FindFirstChild("GunClient") then
        return "Sheriff"
      end
      local n = tool.Name:lower()
      if n == "knife" or n:find("knife") or n:find("scythe") or n:find("battleaxe") then
        return "Murderer"
      end
      if n == "gun" or n == "revolver" or n:find("luger") or n:find("blaster") then
        return "Sheriff"
      end
      return nil
    end
    if char then
      local attr = char:GetAttribute("Role")
      if attr then
        local aStr = tostring(attr):lower()
        if aStr:find("murder") then detectedRole = "Murderer" return end
        if aStr:find("sheriff") or aStr:find("hero") then detectedRole = "Sheriff" end
      end
      for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") then
          local r = scanTool(item)
          if r == "Murderer" then detectedRole = "Murderer" return end
          if r == "Sheriff" then detectedRole = "Sheriff" end
        end
      end
    end
    if bp then
      for _, item in ipairs(bp:GetChildren()) do
        if item:IsA("Tool") then
          local r = scanTool(item)
          if r == "Murderer" then detectedRole = "Murderer" return end
          if r == "Sheriff" then detectedRole = "Sheriff" end
        end
      end
    end
  end)
  return detectedRole
end

local function isPosThreatened(targetPos, radiusMeters, filterMode)
  if not targetPos then return false, nil end
  -- Convert input meters to studs (1m = ~1.2 studs for accurate MM2 avoidance zone)
  local radiusStuds = (radiusMeters or AutoFarmState.SafeAvoidRadius or 20) * 1.2
  filterMode = filterMode or (AutoFarmState.SafeAvoidTarget or "Murderer Only")

  -- Fast Path: Check pre-cached player roles from background scanner thread
  local cache = allPlayersCache
  if cache and #cache > 0 then
    for i = 1, #cache do
      local t = cache[i]
      local r = t.root
      if r and r.Parent then
        local rPos = r.Position
        local dy = math.abs(rPos.Y - targetPos.Y)
        if dy <= 45 then
          local dx = rPos.X - targetPos.X
          local dz = rPos.Z - targetPos.Z
          local flatDist = math.sqrt(dx * dx + dz * dz)
          if flatDist <= radiusStuds then
            local role = t.role or "Innocent"
            local isMatch = (filterMode == "All Players")
                  or (filterMode == "Murderer Only" and role == "Murderer")
                  or (filterMode == "Murderer & Sheriff" and (role == "Murderer" or role == "Sheriff"))
            if isMatch then
              print("[Feature Debug]: Threat detected nearby! TargetRole=" .. tostring(role) .. ", Dist=" .. math.floor(flatDist) .. " studs")
              return true, t.name
            end
          end
        end
      end
    end
    return false, nil
  end

  -- Fallback Path if cache is empty
  local me = LocalPlayer
  for _, plr in ipairs(Players:GetPlayers()) do
    if plr and plr ~= me and plr.Character then
      local r = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("Torso")
      if r then
        local dx = r.Position.X - targetPos.X
        local dz = r.Position.Z - targetPos.Z
        local dy = math.abs(r.Position.Y - targetPos.Y)
        local flatDist = math.sqrt(dx * dx + dz * dz)
        if flatDist <= radiusStuds and dy <= 45 then
          local role = getPlayerRole(plr)
          local isMatch = (filterMode == "All Players")
                or (filterMode == "Murderer Only" and role == "Murderer")
                or (filterMode == "Murderer & Sheriff" and (role == "Murderer" or role == "Sheriff"))
          if isMatch then
            return true, plr
          end
        end
      end
    end
  end
  return false, nil
end
local MM2_MAP_NAMES = {
  "IceCastle", "SkiLodge", "Station", "LogCabin", "Bank2",
"BioLab", "House2", "Factory", "Hospital3", "Hotel",
  "Mansion2", "MilBase", "Office3", "PoliceStation",
  "Workplace", "ResearchFacility", "ChristmasItaly"
}
local airPlatform = { Position = Vector3.new(0, -9999, 0), CFrame = CFrame.new(0, -9999, 0) }
local function getAirPlatform()
  return airPlatform
end
local function setAirPlatformPos(targetPos)
  pcall(function()
    local hrp = getRoot()
    if hrp and targetPos then
      hrp.CFrame = CFrame.new(targetPos.X, targetPos.Y, targetPos.Z)
      hrp.Anchored = true
      hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
  end)
end
local function hideAirPlatform()
end
local function getCoinTouchPart(obj)
  if not obj then return nil end
  local touchPart = nil
  pcall(function()
    if obj.IsFakeCoin then
      touchPart = obj
    elseif obj.Name == "Coin_Server" then
      touchPart = obj
    elseif obj:IsA("BasePart") then
      touchPart = obj
    elseif obj:IsA("Model") or obj:IsA("Folder") then
      touchPart = obj:FindFirstChild("Coin_Server")
        or obj.PrimaryPart
        or obj:FindFirstChildWhichIsA("BasePart", true)
        or obj
    end
  end)
  return touchPart or obj
end
local function getCoinPos(obj)
  if not obj then return nil end
  local part = getCoinTouchPart(obj)
  if part and part.Position then
    return part.Position
  end
  return nil
end
local function isRoundActive()
  local rtp = workspace:FindFirstChild("RoundTimerPart")
  if rtp and rtp:GetAttribute("Time") then
    local t = tonumber(rtp:GetAttribute("Time"))
    if not t or t <= 0 then
      return false
    end
  end
  return true
end
local function findCoinContainer()
  if not isRoundActive() then
    return nil
  end
  for _, obj in ipairs(workspace:GetChildren()) do
    if obj and obj:IsA("Model") and obj.Name ~= "Lobby" then
      local container = obj:FindFirstChild("CoinContainer") or obj:FindFirstChild("Coins")
      if container then
        return container
      end
    end
  end
  local direct = workspace:FindFirstChild("CoinContainer") or workspace:FindFirstChild("Coins")
  if direct then return direct end
  return nil
end
local function getAllMapCoins()
  local coins = {}
  local seen = {}
  local container = findCoinContainer()
  if container then
    for _, obj in ipairs(container:GetChildren()) do
      if obj and obj.Parent and (obj.Name == "Coin_Server" or obj.Name == "Coin" or obj:IsA("BasePart")) then
        local vis = obj:FindFirstChild("CoinVisual")
        local isFlying = vis and vis:IsA("BasePart") and (vis.Position.Y > obj.Position.Y + 2.0)
        if not isFlying and not seen[obj] then
          seen[obj] = true
          coins[#coins + 1] = obj
        end
      end
    end
  end
  for i = 1, #testCoinTargets do
    local obj = testCoinTargets[i]
    if obj and obj.Parent and not seen[obj] then
      seen[obj] = true
      coins[#coins + 1] = obj
    end
  end
  for i = 1, #testCoinDropTargets do
    local obj = testCoinDropTargets[i]
    if obj and obj.Parent and not seen[obj] then
      seen[obj] = true
      coins[#coins + 1] = obj
    end
  end
  return coins
end
local function getCoinContainer()
  return {
    GetChildren = function() return getAllMapCoins() end,
    Parent = workspace,
    Name = "CoinContainer"
  }
end
local function getMapCenterPos()
  local container = findCoinContainer()
  if container and container.Parent and container.Parent:IsA("Model") then
    local mapModel = container.Parent
    pcall(function()
      if mapModel.PrimaryPart then
        return mapModel.PrimaryPart.Position
      end
    end)
    local firstCoin = container:FindFirstChildWhichIsA("BasePart", true)
    if firstCoin then
      return firstCoin.Position
    end
  end
  local lobbySpawn = workspace:FindFirstChild("Lobby") or workspace:FindFirstChild("Spawns")
  if lobbySpawn then
    local spawnPart = lobbySpawn:FindFirstChildWhichIsA("BasePart", true)
    if spawnPart then return spawnPart.Position end
  end
  return Vector3.new(0.29, -94.02, 24.12)
end
local can = true
local coins = 0
local previousCoins = 0
local firstpos = nil
local firstcframe = nil
local function magnitude(a, b)
  local dx = a.X - b.X
  local dy = a.Y - b.Y
  local dz = a.Z - b.Z
  return math.sqrt(dx * dx + dy * dy + dz * dz)
end
local function setNoclip()
  pcall(function()
    local plr = LocalPlayer
    if plr and plr.Character then
      for _, part in ipairs(plr.Character:GetChildren()) do
        if part:IsA("BasePart") then
          part.CanCollide = false
        end
      end
    end
  end)
end
local function setPosAndLook(pos, targetPos)
  firstpos = pos
  if pos then
    if targetPos then
      local lookPos = Vector3.new(targetPos.X, pos.Y, targetPos.Z)
      if (lookPos - pos).Magnitude > 0.05 then
        local ok, cf = pcall(function() return CFrame.lookAt(pos, lookPos) end)
        if ok and cf then
          firstcframe = cf
        else
          firstcframe = CFrame.new(pos.X, pos.Y, pos.Z)
        end
      else
        firstcframe = CFrame.new(pos.X, pos.Y, pos.Z)
      end
    else
      firstcframe = CFrame.new(pos.X, pos.Y, pos.Z)
    end
  else
    firstcframe = nil
  end
end
pcall(function()
  if RunService and RunService.RenderStepped and type(RunService.RenderStepped.Connect) == "function" then
    RunService.RenderStepped:Connect(function()
      pcall(function()
        if not AutoFarmState.Enabled then return end
        local plr = LocalPlayer
        local char = plr and plr.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if AutoFarmState.Method == "Undermap" then
          local hum = char:FindFirstChildOfClass("Humanoid") or char:FindFirstChild("Humanoid")
          if hum then
            pcall(function()
              if hum.Address and type(memory_write) == "function" then
                memory_write("float", hum.Address + 0x18C + 8, 0)
              end
            end)
            pcall(function()
              hum.Health = 0
            end)
          end
          if not firstcframe and not firstpos then
            local safePos = Vector3.new(1.94, -97.21, 15.65)
            setPosAndLook(safePos, nil)
          end
        end
        if firstcframe then
          hrp.CFrame = firstcframe
          hrp.Velocity = Vector3.new(0, 0, 0)
          pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end)
        elseif firstpos then
          hrp.Position = firstpos
          hrp.Velocity = Vector3.new(0, 0, 0)
          pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end)
        end
        if AutoFarmState.Method ~= "Teleport" then
          setNoclip()
        end
      end)
    end)
  end
end)
local function resetCharacter()
  pcall(function()
    local char = LocalPlayer and LocalPlayer.Character
    if char then
      local hum = char:FindFirstChildOfClass("Humanoid") or char:FindFirstChild("Humanoid")
      if hum then
        pcall(function()
          hum.Health = 0
        end)
      else
        pcall(function()
          char:BreakJoints()
        end)
      end
    end
  end)
end

local function tween(object, target, spd)
  can = false
  spd = math.max(1, tonumber(spd) or AutoFarmState.Speed or 25)
  local isUndermap = (AutoFarmState.Method == "Undermap")
  local flyOffset = AutoFarmState.UndermapOffset or 6    -- глубина полёта под картой (Y - 6)
  local pickupOffset = AutoFarmState.PickupOffset or 3 -- глубина подбора монеты (Y - 3, ближе к монете)
  local coinPos = target.Position
  local now = os.clock()
  local cPos = getCoinPos(target) or coinPos
  local touchPart = getCoinTouchPart(target) or target
  if cPos then
    local posKey = string.format("%.1f_%.1f_%.1f", cPos.X, cPos.Y, cPos.Z)
    visitedCoinsMap[target] = now + 4.0
    visitedCoinsMap[posKey] = now + 4.0
    if touchPart then visitedCoinsMap[touchPart] = now + 4.0 end
  end
  if isUndermap then
    local sx, sy, sz
    if firstpos then
      sx, sy, sz = firstpos.X, firstpos.Y, firstpos.Z
    else
      sx, sy, sz = object.Position.X, object.Position.Y - flyOffset, object.Position.Z
    end
    local tx, ty, tz = coinPos.X, coinPos.Y - flyOffset, coinPos.Z
    local dx = tx - sx
    local dy = ty - sy
    local dz = tz - sz
    local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
    if dist < 0.5 or dist > 200 or AutoFarmState.IsFirstCoinOfRound then
      AutoFarmState.IsFirstCoinOfRound = false
      setPosAndLook(Vector3.new(tx, ty, tz), coinPos)
      object.CFrame = firstcframe
      if isValid(target) and touchPart and type(firetouchinterest) == "function" then
        pcall(function()
          firetouchinterest(object, touchPart, 0)
          task.wait(0.02)
          firetouchinterest(object, touchPart, 1)
        end)
      end
    else
      local duration = dist / spd
      local startTime = os.clock()
      local lastThreatCheck = 0
      while true do
        local elapsed = os.clock() - startTime
        local alpha = elapsed / duration
        if alpha >= 1 then alpha = 1 end
        if not AutoFarmState.Enabled or not isValid(target) or not isAlive() then break end
        local cx = sx + dx * alpha
        local cy = sy + dy * alpha
        local cz = sz + dz * alpha
        local nowSec = os.clock()
        if AutoFarmState.SafeAvoidEnabled and AutoFarmState.SafeMidFlightEvade and (nowSec - lastThreatCheck) >= 0.1 then
          lastThreatCheck = nowSec
          local triggerZoneRadius = 15.0 -- 15m trigger zone mid-flight
          local isThreat, threatPlr = isPosThreatened(Vector3.new(cx, coinPos.Y, cz), triggerZoneRadius, AutoFarmState.SafeAvoidTarget)
          if not isThreat then
            isThreat, threatPlr = isPosThreatened(coinPos, triggerZoneRadius, AutoFarmState.SafeAvoidTarget)
          end
          if isThreat then
            visitedCoinsMap[target] = nowSec + 10.0
            setPosAndLook(Vector3.new(cx, cy, cz), nil)
            task.wait(0.4)
            can = true
            return -- Exit tween smoothly without rising, touching coin, or TPing!
          end
        end
        setPosAndLook(Vector3.new(cx, cy, cz), coinPos)
        object.CFrame = firstcframe
        if alpha >= 1 then break end
        task.wait(0.01)
      end
    end
    local pickupY = coinPos.Y - pickupOffset
    local riseSteps = 4
    for i = 1, riseSteps do
      if not AutoFarmState.Enabled then break end
      local a = i / riseSteps
      local smoothY = ty + (pickupY - ty) * a
      setPosAndLook(Vector3.new(tx, smoothY, tz), coinPos)
      object.CFrame = firstcframe
      task.wait(0.01)
    end
    if isValid(target) and touchPart and type(firetouchinterest) == "function" then
      pcall(function()
        firetouchinterest(object, touchPart, 0)
        task.wait(0.02)
        firetouchinterest(object, touchPart, 1)
      end)
    end
    for i = 1, riseSteps do
      if not AutoFarmState.Enabled then break end
      local a = i / riseSteps
      local smoothY = pickupY + (ty - pickupY) * a
      setPosAndLook(Vector3.new(tx, smoothY, tz), coinPos)
      object.CFrame = firstcframe
      task.wait(0.01)
    end
    setPosAndLook(Vector3.new(tx, ty, tz), coinPos)
    object.CFrame = firstcframe
  else
    local startPos = firstpos or object.Position
    local targetPos = Vector3.new(coinPos.X, coinPos.Y + 2.0, coinPos.Z)
    local dist = magnitude(startPos, targetPos)
    if dist < 0.5 or dist > 200 or AutoFarmState.IsFirstCoinOfRound then
      AutoFarmState.IsFirstCoinOfRound = false
      setPosAndLook(targetPos, coinPos)
      object.CFrame = firstcframe
      if type(firetouchinterest) == "function" and isValid(target) and touchPart then
        pcall(function()
          firetouchinterest(object, touchPart, 0)
          task.wait(0.02)
          firetouchinterest(object, touchPart, 1)
        end)
      end
    else
      local duration = dist / spd
      local startTime = os.clock()
      local lastThreatCheck = 0
      while true do
        local elapsed = os.clock() - startTime
        local alpha = elapsed / duration
        if alpha >= 1 then alpha = 1 end
        if not AutoFarmState.Enabled or not isValid(target) or not isAlive() then break end
        local cx = startPos.X + (targetPos.X - startPos.X) * alpha
        local cy = startPos.Y + (targetPos.Y - startPos.Y) * alpha
        local cz = startPos.Z + (targetPos.Z - startPos.Z) * alpha
        local nowSec = os.clock()
        if AutoFarmState.SafeAvoidEnabled and AutoFarmState.SafeMidFlightEvade and (nowSec - lastThreatCheck) >= 0.1 then
          lastThreatCheck = nowSec
          local triggerZoneRadius = 15.0 -- 15m trigger zone mid-flight
          local isThreat, threatPlr = isPosThreatened(Vector3.new(cx, cy, cz), triggerZoneRadius, AutoFarmState.SafeAvoidTarget)
          if not isThreat then
            isThreat, threatPlr = isPosThreatened(coinPos, triggerZoneRadius, AutoFarmState.SafeAvoidTarget)
          end
          if isThreat then
            visitedCoinsMap[target] = nowSec + 10.0
            local dipY = coinPos.Y - 6.0
            setPosAndLook(Vector3.new(cx, dipY, cz), nil)
            task.wait(0.4)
            can = true
            return -- Exit tween under floor, seamlessly continue farming from current position!
          end
        end
        setPosAndLook(Vector3.new(cx, cy, cz), coinPos)
        object.CFrame = firstcframe
        if alpha >= 1 then break end
        task.wait(0.01)
      end
    end
    setPosAndLook(Vector3.new(coinPos.X, coinPos.Y + 2.0, coinPos.Z), coinPos)
    object.CFrame = firstcframe
    if type(firetouchinterest) == "function" and isValid(target) and touchPart then
      pcall(function()
        firetouchinterest(object, touchPart, 0)
        task.wait(0.02)
        firetouchinterest(object, touchPart, 1)
      end)
    end
  end
  local coinDelay = math.max(0.1, AutoFarmState.CoinDelay or 0.1)
  task.wait(coinDelay)
  can = true
end
task.spawn(function()
  while true do
    if AutoFarmState.Enabled then
      local ok, err = pcall(function()
        local plr = LocalPlayer
        if not plr then return end
        if not isAlive() then
          firstpos = nil
          firstcframe = nil
          return
        end
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not char or not hrp then
          firstpos = nil
          firstcframe = nil
          return
        end
        local rtp = workspace:FindFirstChild("RoundTimerPart")
        local timerValue = rtp and rtp:GetAttribute("Time") and tonumber(rtp:GetAttribute("Time"))
        local container = findCoinContainer()
        if not isRoundActive() or not container or (timerValue and timerValue <= 0) then
          visitedCoinsMap = {}
          AutoFarmState.IsFirstCoinOfRound = true
          if AutoFarmState.Method == "Undermap" then
            local safePos = Vector3.new(1.94, -97.21, 15.65)
            setPosAndLook(safePos, nil)
            pcall(function()
              hrp.CFrame = firstcframe or CFrame.new(safePos.X, safePos.Y, safePos.Z)
              hrp.Velocity = Vector3.new(0, 0, 0)
              pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end)
            end)
          else
            firstpos = nil
            firstcframe = nil
          end
          return
        end
        pcall(function()
          coins = tonumber(plr.PlayerGui.MainGUI.Game.CoinBags.Container.Coin.CurrencyFrame.Icon.Coins.Text) or 0
        end)
        -- [NUEVO CAMBIO] Lógica de sumatoria para Estadísticas y Webhooks
        if coins > previousCoins then
            local gained = coins - previousCoins
            
            -- Sanity check: Evita sumar bugs visuales si la UI de MM2 falla y da un salto irreal
            if gained <= 50 then
                FarmStats.SessionCoins = (FarmStats.SessionCoins or 0) + gained
                FarmStats.TotalCoinsAllTime = (FarmStats.TotalCoinsAllTime or 0) + gained
                SaveStats() -- Guarda en tu archivo .json automáticamente
            end
        end
        -- Actualizamos siempre para el siguiente frame (incluso si baja a 0 por nueva ronda)
        previousCoins = coins
        if coins >= (AutoFarmState.MaxCoins or 50) then
          if AutoFarmState.FullBagAction == "Stay Under Map" then
            local safePos = Vector3.new(1.94, -97.21, 15.65)
            setPosAndLook(safePos, nil)
            pcall(function()
              hrp.CFrame = firstcframe or CFrame.new(safePos.X, safePos.Y, safePos.Z)
              hrp.Velocity = Vector3.new(0, 0, 0)
              pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end)
            end)
          else -- "Reset / Die" mode: clear position lock so character unfreezes and falls into the void
            firstpos = nil
            firstcframe = nil
            if not AutoFarmState.FullBagResetDone then
              AutoFarmState.FullBagResetDone = true
              pcall(function()
                hrp.CFrame = CFrame.new(hrp.Position.X, -200, hrp.Position.Z)
                hrp.Velocity = Vector3.new(0, -200, 0)
                pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0, -200, 0) end)
              end)
            end
          end
          return
        else
          AutoFarmState.FullBagResetDone = false
        end
        if not container then
          if AutoFarmState.Method == "Undermap" then
            local safePos = Vector3.new(1.94, -97.21, 15.65)
            setPosAndLook(safePos, nil)
            pcall(function()
              hrp.CFrame = firstcframe or CFrame.new(safePos.X, safePos.Y, safePos.Z)
              hrp.Velocity = Vector3.new(0, 0, 0)
              pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end)
            end)
          end
          return
        end
        if AutoFarmState.Method == "Undermap" and not firstpos then
          local safePos = Vector3.new(1.94, -97.21, 15.65)
          setPosAndLook(safePos, nil)
          hrp.CFrame = firstcframe or CFrame.new(safePos.X, safePos.Y, safePos.Z)
        end
        local coin = nil
        local best = math.huge
        local now = os.clock()
        for _, obj in ipairs(container:GetChildren()) do
          if isValid(obj) then
            local cPos = getCoinPos(obj)
            if cPos then
              local touchPart = getCoinTouchPart(obj)
              local posKey = string.format("%.1f_%.1f_%.1f", cPos.X, cPos.Y, cPos.Z)
              local isVisited = (visitedCoinsMap[obj] and now < visitedCoinsMap[obj])
                     or (visitedCoinsMap[posKey] and now < visitedCoinsMap[posKey])
                     or (touchPart and visitedCoinsMap[touchPart] and now < visitedCoinsMap[touchPart])
              if not isVisited then
                local isThreatened = false
                if AutoFarmState.SafeAvoidEnabled then
                  isThreatened = isPosThreatened(cPos, AutoFarmState.SafeAvoidRadius, AutoFarmState.SafeAvoidTarget)
                end
                if not isThreatened then
                  local dist = magnitude(cPos, hrp.Position)
                  if dist < best then
                    best = dist
                    coin = obj
                  end
                end
              end
            end
          end
        end
        if not coin then
          visitedCoinsMap = {}
          local safePos = Vector3.new(1.94, -97.21, 15.65)
          setPosAndLook(safePos, nil)
          pcall(function()
            hrp.CFrame = firstcframe or CFrame.new(safePos.X, safePos.Y, safePos.Z)
            hrp.Velocity = Vector3.new(0, 0, 0)
            pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end)
          end)
          return
        end
        if coin and can then
          if AutoFarmState.Method == "Teleport" then
            can = false
            local cPos = getCoinPos(coin) or coin.Position
            local posKey = string.format("%.1f_%.1f_%.1f", cPos.X, cPos.Y, cPos.Z)
            local touchPart = getCoinTouchPart(coin) or coin
            visitedCoinsMap[coin] = now + 4.0
            visitedCoinsMap[posKey] = now + 4.0
            if touchPart then visitedCoinsMap[touchPart] = now + 4.0 end
            local ok, err = pcall(function()
              firstpos = nil
              firstcframe = nil
              if hrp then
                hrp.CFrame = CFrame.new(cPos.X, cPos.Y, cPos.Z)
                hrp.Velocity = Vector3.new(0, 0, 0)
                pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end)
              end
              if type(firetouchinterest) == "function" and touchPart then
                pcall(function()
                  firetouchinterest(hrp, touchPart, 0)
                  task.wait(0.02)
                  firetouchinterest(hrp, touchPart, 1)
                end)
              end
              local cooldown = math.max(0.3, AutoFarmState.TeleportCooldown or 0.3)
              task.wait(cooldown)
            end)
            if not ok then
            end
            can = true
          else
            can = false
            local cPos = getCoinPos(coin) or coin.Position
            local posKey = string.format("%.1f_%.1f_%.1f", cPos.X, cPos.Y, cPos.Z)
            local touchPart = getCoinTouchPart(coin) or coin
            visitedCoinsMap[coin] = now + 4.0
            visitedCoinsMap[posKey] = now + 4.0
            if touchPart then visitedCoinsMap[touchPart] = now + 4.0 end
            local ok, err = pcall(function()
              tween(hrp, coin, AutoFarmState.UndermapSpeed or AutoFarmState.Speed or 25)
            end)
            if not ok then
            end
            can = true
          end
        end
      end)
      if not ok then
      end
    else
      firstpos = nil
      firstcframe = nil
    end
    task.wait(0.05)
  end
end)
local function BuildWebhookMessage()
  local lines = {
    "[One Protocol 8.8.26_2beta - AutoFarm Stats Report]",
    "----------------------------------------"
  }
  local sessionElapsed = math.max(1, os.clock() - FarmStats.SessionStartTime)
  local coinsPerHour = math.floor((FarmStats.SessionCoins / sessionElapsed) * 3600)
  if FarmStats.LogTotalCoins then
    lines[#lines + 1] = "Total Coins (All-Time): " .. tostring(FarmStats.TotalCoinsAllTime)
  end
  if FarmStats.LogSessionCoins then
    lines[#lines + 1] = "Coins (This Session): " .. tostring(FarmStats.SessionCoins)
  end
  if FarmStats.LogCoinsPerHour then
    lines[#lines + 1] = "Coins / Hour Rate: ~" .. tostring(coinsPerHour) .. " coins/hr"
  end
  lines[#lines + 1] = "----------------------------------------"
  return table.concat(lines, "\n")
end
local AutoGrabGunEnabled = false
local function getRootPart()
  return getRoot()
end
local function teleportToPos(pos)
  if not pos then
    return false
  end
  local root = getRootPart()
  if root then
    local px = type(pos) == "userdata" and pos.X or (pos.x or pos[1] or 0)
    local py = type(pos) == "userdata" and pos.Y or (pos.y or pos[2] or 0)
    local pz = type(pos) == "userdata" and pos.Z or (pos.z or pos[3] or 0)
    pcall(function()
      root.CFrame = CFrame.new(px, py + 3, pz)
    end)
    return true
  else
    return false
  end
end
local function findGunDropPart()
  local glist = gunDropTargets
  for i = 1, #glist do
    local part = glist[i]
    if part and part.Parent then
      return part
    end
  end
  for i = 1, #testGunDropTargets do
    local part = testGunDropTargets[i]
    if part and part.Parent then
      return part
    end
  end
  local found = nil
  pcall(function()
    for _, obj in ipairs(workspace:GetChildren()) do
      if obj and obj.Parent and (obj.Name == "GunDrop" or obj.Name == "Gun" or obj.Name == "WeaponDrop") then
        if obj:IsA("BasePart") then
          found = obj
          break
        else
          local p = obj:FindFirstChildWhichIsA("BasePart", true)
          if p then
            found = p
            break
          end
        end
      end
    end
  end)
  return found
end
local function grabGunAction()
  local gunPart = findGunDropPart()
  if not gunPart then
    return false
  end
  local root = getRootPart()
  if not root then
    return false
  end
  local savedCFrame = root.CFrame
  local savedPos = root.Position
  local gunPos = gunPart.Position
  teleportToPos(gunPos)
  if firetouchinterest then
    pcall(function()
      firetouchinterest(root, gunPart, 0)
      task.wait(0.05)
      firetouchinterest(root, gunPart, 1)
    end)
  end
  task.wait(0.1)
  pcall(function()
    root.CFrame = savedCFrame
  end)
  return true
end
local function teleportToRolePlayer(roleTarget)
  local list = allPlayersCache or {}
  for i = 1, #list do
    local t = list[i]
    if t.role == roleTarget and t.root and t.root.Parent then
      return teleportToPos(t.root.Position)
    end
  end
  local me = LocalPlayer and LocalPlayer.Name or ""
  for _, plr in ipairs(Players:GetPlayers()) do
    if plr and plr.Name ~= me then
      local role = getPlayerRole(plr)
      if role == roleTarget and plr.Character then
        local root = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character.PrimaryPart
        if root then
          return teleportToPos(root.Position)
        end
      end
    end
  end
  return false
end
local function printCurrentPosition()
  local root = getRootPart()
  if root then
    local p = root.Position
    local cf = root.CFrame
  else
  end
end
task.spawn(function()
  while true do
    task.wait(0.5)
    if AutoGrabGunEnabled then
      local gunPart = findGunDropPart()
      if gunPart then
        pcall(function() grabGunAction() end)
      end
    end
  end
end)
local function getForwardPosition(dist)
  dist = dist or 10
  local root = getRootPart() or getRoot()
  if not root then return nil end
  local pos = root.Position
  local look = Vector3.new(0, 0, -1)
  pcall(function()
    if root.CFrame and root.CFrame.LookVector then
      look = root.CFrame.LookVector
    end
  end)
  if not look or (look.X == 0 and look.Y == 0 and look.Z == 0) then
    look = Vector3.new(0, 0, -1)
  end
  local targetPos = Vector3.new(
    pos.X + (look.X * dist),
    pos.Y,
    pos.Z + (look.Z * dist)
  )
  local dx = targetPos.X - pos.X
  local dz = targetPos.Z - pos.Z
  if (dx * dx + dz * dz) < 1 then
    targetPos = Vector3.new(pos.X + dist, pos.Y, pos.Z)
  end
  return targetPos, pos
end
local function createFakeGunDrop()
  local targetPos, playerPos = getForwardPosition(8)
  if targetPos then
    local fakePart = {
      Position = targetPos,
      Parent = workspace,
      Name = "GunDrop"
    }
    pcall(function()
      if Instance and Instance.new then
        local realPart = Instance.new("Part")
        realPart.Name = "GunDrop"
        realPart.Size = Vector3.new(3, 1, 1)
        realPart.Position = targetPos
        realPart.Color = Color3.fromRGB(255, 200, 0)
        realPart.Material = Enum.Material.Neon
        realPart.Anchored = true
        realPart.CanCollide = false
        realPart.Parent = workspace
        fakePart = realPart
      end
    end)
    testGunDropTargets[#testGunDropTargets + 1] = fakePart
    gunDropTargets[#gunDropTargets + 1] = fakePart
  else
  end
end
local function clearFakeGunDrops()
  testGunDropTargets = {}
  gunDropTargets = {}
end
local function getRandomAroundPosition(minDist, maxDist)
  minDist = minDist or 20
  maxDist = maxDist or 100
  local root = getRoot()
  if not root then return nil, nil end
  local pos = root.Position
  math.randomseed(math.floor(os.clock() * 1000) + math.random(1, 9999))
  local angle = math.rad(math.random(0, 360))
  local dist = math.random(minDist, maxDist)
  local dx = math.cos(angle) * dist
  local dz = math.sin(angle) * dist
  local targetPos = Vector3.new(pos.X + dx, pos.Y, pos.Z + dz)
  return targetPos, pos
end
local function createFakeCoin()
  local targetPos, playerPos = getRandomAroundPosition(20, 100)
  if targetPos then
    local fakeCoin = {
      Position = targetPos,
      Name = "Coin_Server",
      IsFakeCoin = true,
      TouchInterest = true,
      Parent = workspace
    }
    pcall(function()
      if Instance and Instance.new then
        local realPart = Instance.new("Part")
        if realPart then
          realPart.Name = "Coin_Server"
          realPart.Size = Vector3.new(2, 2, 0.5)
          realPart.Position = targetPos
          realPart.Color = Color3.fromRGB(255, 215, 0)
          realPart.Material = Enum.Material.Neon
          realPart.Anchored = true
          realPart.CanCollide = false
          realPart.Parent = workspace
          fakeCoin = realPart
          fakeCoin.IsFakeCoin = true
        end
      end
    end)
    testCoinDropTargets[#testCoinDropTargets + 1] = fakeCoin
    coinDropTargets[#coinDropTargets + 1] = fakeCoin
    testCoinTargets[#testCoinTargets + 1] = fakeCoin
    coinTargets[#coinTargets + 1] = fakeCoin
    _cachedCoinContainer = nil
  else
  end
end
local function spawnMassCoins()
  local targetPos, playerPos = getForwardPosition(20)
  if playerPos then
    math.randomseed(math.floor(os.clock() * 1000))
    for i = 1, 10 do
      local angle = (i / 10) * (math.pi * 2)
      local dist = math.random(15, 50)
      local dx = math.cos(angle) * dist
      local dz = math.sin(angle) * dist
      local coinPos = Vector3.new(playerPos.X + dx, playerPos.Y, playerPos.Z + dz)
      local fakeCoin = {
        Position = coinPos,
        Name = "Coin_Server",
        IsFakeCoin = true,
        TouchInterest = true,
        Parent = workspace
      }
      pcall(function()
        if Instance and Instance.new then
          local realPart = Instance.new("Part")
          if realPart then
            realPart.Name = "Coin_Server"
            realPart.Size = Vector3.new(2, 2, 0.5)
            realPart.Position = coinPos
            realPart.Color = Color3.fromRGB(255, 215, 0)
            realPart.Material = Enum.Material.Neon
            realPart.Anchored = true
            realPart.CanCollide = false
            realPart.Parent = workspace
            fakeCoin = realPart
            fakeCoin.IsFakeCoin = true
          end
        end
      end)
      testCoinDropTargets[#testCoinDropTargets + 1] = fakeCoin
      coinDropTargets[#coinDropTargets + 1] = fakeCoin
      testCoinTargets[#testCoinTargets + 1] = fakeCoin
      coinTargets[#coinTargets + 1] = fakeCoin
    end
    _cachedCoinContainer = nil
  else
  end
end
local infCoinLoopRunning = false
local infCoinBtnRef = nil
local function toggleInfCoinLoop()
  infCoinLoopRunning = not infCoinLoopRunning
  if infCoinBtnRef and infCoinBtnRef.SetText then
    infCoinBtnRef:SetText(infCoinLoopRunning and "[ON] Spawn Inf Coins" or "Spawn Inf Coins (Loop)")
  end
  if infCoinLoopRunning then
    task.spawn(function()
      while infCoinLoopRunning do
        pcall(function()
          if #testCoinTargets < 2 then
            createFakeCoin()
          end
        end)
        task.wait(0.4)
      end
    end)
  end
end
local function clearFakeCoins()
  infCoinLoopRunning = false
  if infCoinBtnRef and infCoinBtnRef.SetText then
    infCoinBtnRef:SetText("Spawn Inf Coins (Loop)")
  end
  testCoinDropTargets = {}
  coinDropTargets = {}
  testCoinTargets = {}
  coinTargets = {}
  _cachedCoinContainer = nil
end
local mainBg     = createDraw("Square", { Filled = true, Color = Colors.Bg, ZIndex = 0 })
local mainBorder = createDraw("Square", { Filled = false, Color = Colors.Accent, Thickness = 1, ZIndex = 3 })
local headerBg   = createDraw("Square", { Filled = true, Color = Colors.HeaderBg, ZIndex = 2 })
local headerLine = createDraw("Line",   { Color = Colors.Accent, Thickness = 1, ZIndex = 3 })
local headerText = createDraw("Text",   { Text = "One Protocol 8.8.26_2beta", Size = 13, Color = Colors.TextActive, Font = Drawing.Fonts.Plex, ZIndex = 4 })
local sideBg     = createDraw("Square", { Filled = true, Color = Colors.SidebarBg, ZIndex = 2 })
local sideLine   = createDraw("Line",   { Color = Colors.Accent, Thickness = 1, ZIndex = 3 })
local configBtnBox = createDraw("Square", { Filled = true, Color = Colors.ButtonBg, Visible = false, ZIndex = 3 })
local configBtnBorder = createDraw("Square", { Filled = false, Color = Colors.ButtonBorder, Thickness = 1, Visible = false, ZIndex = 4 })
local configBtnTxt = createDraw("Text", { Text = "[ Config ]", Size = 11, Color = Colors.TextDim, Center = true, Font = Drawing.Fonts.Plex, Visible = false, ZIndex = 5 })
local settingsBtnBox = createDraw("Square", { Filled = true, Color = Colors.ButtonBg, Visible = false, ZIndex = 3 })
local settingsBtnBorder = createDraw("Square", { Filled = false, Color = Colors.ButtonBorder, Thickness = 1, Visible = false, ZIndex = 4 })
local settingsBtnTxt = createDraw("Text", { Text = "[ Settings ]", Size = 11, Color = Colors.TextDim, Center = true, Font = Drawing.Fonts.Plex, Visible = false, ZIndex = 5 })
local LibraryData = {
  Tabs = {},
  TabOrder = {},
  StatusLabels = {}
}
local function IsHover(mX, mY, pX, pY, w, h, pad)
  pad = pad or 2
  return mX >= (pX - pad) and mX <= (pX + w + pad) and mY >= (pY - pad) and mY <= (pY + h + pad)
end
local function GetClipboardText()
  local text = nil
  local fn = getclipboard or get_clipboard or readclipboard or fromclipboard or (syn and syn.get_clipboard) or (Clipboard and Clipboard.get) or getClipboard
  if fn then
    pcall(function()
      text = fn()
    end)
  end
  if type(text) == "string" then
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    if #text == 0 then text = nil end
  else
    text = nil
  end
  return text
end
local function SetFocus(newInput)
  if UIState.FocusedInput == newInput then return end
  local oldInput = UIState.FocusedInput
  if oldInput then
    if oldInput.Callback and oldInput.Value ~= "" then
      local val = oldInput.Value
      task.spawn(function()
        oldInput.Callback(val)
      end)
    end
  end
  pcall(function()
    local char = LocalPlayer and LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
      if newInput then
        pcall(function() hum.WalkSpeed = 0 end)
        pcall(function() hum.JumpPower = 0 end)
      else
        pcall(function() hum.WalkSpeed = 16 end)
        pcall(function() hum.JumpPower = 50 end)
      end
    end
  end)
  UIState.FocusedInput = newInput
end
local function hideTabElements(tTab)
  if not tTab then return end
  for _, sec in ipairs(tTab.Sections or {}) do
    if sec.Box then sec.Box.Visible = false end
    if sec.Border then sec.Border.Visible = false end
    if sec.HeaderLine then sec.HeaderLine.Visible = false end
    if sec.TitleText then sec.TitleText.Visible = false end
    for _, el in ipairs(sec.Elements or {}) do
      if el.Box then el.Box.Visible = false end
      if el.Border then el.Border.Visible = false end
      if el.Fill then el.Fill.Visible = false end
      if el.Txt then el.Txt.Visible = false end
      if el.LabelTxt then el.LabelTxt.Visible = false end
      if el.ValTxt then el.ValTxt.Visible = false end
      if el.PopupBg then el.PopupBg.Visible = false end
      if el.PopupBorder then el.PopupBorder.Visible = false end
      if el.OptionItems then
        for _, optItem in ipairs(el.OptionItems) do
          if optItem.Box then optItem.Box.Visible = false end
          if optItem.Border then optItem.Border.Visible = false end
          if optItem.Txt then optItem.Txt.Visible = false end
        end
      end
    end
  end
end
local uiWasVisible = nil
local lastActiveTab = nil
local function RenderUI()
  if not UIState.Visible then
    if uiWasVisible ~= false then
      uiWasVisible = false
      for _, d in ipairs(Drawings) do
        pcall(function() d.Visible = false end)
      end
    end
    return
  end
  uiWasVisible = true
  if lastActiveTab and lastActiveTab ~= UIState.ActiveTab then
    hideTabElements(LibraryData.Tabs[lastActiveTab])
  end
  lastActiveTab = UIState.ActiveTab
  if currentThemeName == "Rainbow (Dynamic)" then
    local hue = (os.clock() * 0.25) % 1
    local rainbowCol = Color3.fromHSV(hue, 0.85, 1.0)
    Colors.Accent = rainbowCol
    Colors.CheckActive = rainbowCol
    Colors.SelectedBg = Color3.fromRGB(math.floor(rainbowCol.R * 255 * 0.18), math.floor(rainbowCol.G * 255 * 0.18), math.floor(rainbowCol.B * 255 * 0.18))
  end
  local size = Vector2.new(UIDebug.WindowWidth, UIDebug.WindowHeight)
  local pos = UIState.Position
  mainBg.Color = Colors.Bg; mainBg.Position = pos; mainBg.Size = size; mainBg.Visible = true
  mainBorder.Color = Colors.Accent; mainBorder.Position = pos; mainBorder.Size = size; mainBorder.Visible = true
  headerBg.Color = Colors.HeaderBg; headerBg.Position = pos; headerBg.Size = Vector2.new(size.X, 24); headerBg.Visible = true
  headerLine.Color = Colors.Accent; headerLine.From = Vector2.new(pos.X, pos.Y + 24); headerLine.To = Vector2.new(pos.X + size.X, pos.Y + 24); headerLine.Visible = true
  if currentWindowTitle then headerText.Text = currentWindowTitle end
  headerText.Font = UIDebug.FontType; headerText.Position = Vector2.new(pos.X + 8, pos.Y + 4); headerText.Visible = true
  local sideWidth = UIDebug.SideWidth
  sideBg.Color = Colors.SidebarBg; sideBg.Position = Vector2.new(pos.X, pos.Y + 25); sideBg.Size = Vector2.new(sideWidth, size.Y - 25); sideBg.Visible = true
  sideLine.Color = Colors.Accent; sideLine.From = Vector2.new(pos.X + sideWidth, pos.Y + 25); sideLine.To = Vector2.new(pos.X + sideWidth, pos.Y + size.Y); sideLine.Visible = true
  local tabY = pos.Y + 34
  local allTabs = LibraryData.TabOrder
  if UIState.ActiveTab == "" and #allTabs > 0 then
    UIState.ActiveTab = allTabs[1]
  end
  for _, tabName in ipairs(allTabs) do
    if tabName ~= "Settings" and tabName ~= "Config" then
      local tabData = LibraryData.Tabs[tabName]
      if tabData then
        tabData.DrawText.Font = UIDebug.FontType
        tabData.DrawText.Position = Vector2.new(pos.X + 10, tabY)
        tabData.DrawText.Color = (tabName == UIState.ActiveTab) and Colors.TextActive or Colors.TextDim
        tabData.DrawText.Visible = true
      end
      tabY = tabY + 34
    end
  end
  local configY = pos.Y + size.Y - 48
  local isConfigActive = (UIState.ActiveTab == "Config")
  configBtnBox.Position = Vector2.new(pos.X + 6, configY)
  configBtnBox.Size = Vector2.new(sideWidth - 12, 18)
  configBtnBox.Color = isConfigActive and Colors.SelectedBg or Colors.ButtonBg
  configBtnBox.Visible = true
  configBtnBorder.Position = Vector2.new(pos.X + 6, configY)
  configBtnBorder.Size = Vector2.new(sideWidth - 12, 18)
  configBtnBorder.Color = isConfigActive and Colors.Accent or Colors.ButtonBorder
  configBtnBorder.Visible = true
  configBtnTxt.Font = UIDebug.FontType
  configBtnTxt.Position = Vector2.new(pos.X + math.floor(sideWidth / 2), configY + UIDebug.BtnTextYOffset)
  configBtnTxt.Color = isConfigActive and Colors.Accent or Colors.TextDim
  configBtnTxt.Visible = true
  local settingsY = pos.Y + size.Y - 26
  local isSettingsActive = (UIState.ActiveTab == "Settings")
  settingsBtnBox.Position = Vector2.new(pos.X + 6, settingsY)
  settingsBtnBox.Size = Vector2.new(sideWidth - 12, 18)
  settingsBtnBox.Color = isSettingsActive and Colors.SelectedBg or Colors.ButtonBg
  settingsBtnBox.Visible = true
  settingsBtnBorder.Position = Vector2.new(pos.X + 6, settingsY)
  settingsBtnBorder.Size = Vector2.new(sideWidth - 12, 18)
  settingsBtnBorder.Color = isSettingsActive and Colors.Accent or Colors.ButtonBorder
  settingsBtnBorder.Visible = true
  settingsBtnTxt.Font = UIDebug.FontType
  settingsBtnTxt.Position = Vector2.new(pos.X + math.floor(sideWidth / 2), settingsY + UIDebug.BtnTextYOffset)
  settingsBtnTxt.Color = isSettingsActive and Colors.Accent or Colors.TextDim
  settingsBtnTxt.Visible = true
  local mainX = pos.X + sideWidth + 6
  local mainY = pos.Y + 29
  local colW  = (size.X - sideWidth - 16) / 2
  local rowH  = (size.Y - 36) / 2
  local tTab = LibraryData.Tabs[UIState.ActiveTab]
  if tTab then
    local secX = mainX
    local secY = mainY
    local secCount = #(tTab.Sections or {})
    for _, sec in ipairs(tTab.Sections or {}) do
      local secH = (secCount <= 2) and (rowH * 2 + 4) or rowH
      sec.Box.Color = Colors.BoxBg; sec.Box.Position = Vector2.new(secX, secY); sec.Box.Size = Vector2.new(colW, secH); sec.Box.Transparency = isWallpaperActive and math.min(1.0, glassTrans + 0.1) or 1.0; sec.Box.Visible = true
      sec.Border.Color = Colors.ButtonBorder; sec.Border.Position = Vector2.new(secX, secY); sec.Border.Size = Vector2.new(colW, secH); sec.Border.Visible = true
      sec.HeaderLine.Color = Colors.Accent; sec.HeaderLine.From = Vector2.new(secX + 4, secY + 20); sec.HeaderLine.To = Vector2.new(secX + colW - 4, secY + 20); sec.HeaderLine.Visible = true
      sec.TitleText.Color = Colors.Accent; sec.TitleText.Font = UIDebug.FontType; sec.TitleText.Position = Vector2.new(secX + math.floor(colW / 2), secY + UIDebug.HeaderYOffset); sec.TitleText.Visible = true
      local totalContentH = 0
      for _, el in ipairs(sec.Elements or {}) do
        if not el.IsHidden then
          if el.Type == "Button" then totalContentH = totalContentH + UIDebug.BtnHeight + 4
          elseif el.Type == "Toggle" then totalContentH = totalContentH + 16
          elseif el.Type == "Label" then totalContentH = totalContentH + 14
          elseif el.Type == "Input" then totalContentH = totalContentH + 20
          elseif el.Type == "Slider" then totalContentH = totalContentH + 22
          elseif el.Type == "Dropdown" then totalContentH = totalContentH + 20
          end
        end
      end
      sec.MaxContentH = totalContentH + 12
      local maxScroll = math.max(0, sec.MaxContentH - (secH - 32))
      sec.ScrollY = math.clamp(sec.ScrollY or 0, 0, maxScroll)
      if sec.ScrollTrack then sec.ScrollTrack.Visible = false end
      if sec.ScrollThumb then sec.ScrollThumb.Visible = false end
      if sec.ScrollUpBtn then sec.ScrollUpBtn.Visible = false end
      if sec.ScrollDownBtn then sec.ScrollDownBtn.Visible = false end
      local openPopY1, openPopY2, openEl = 0, 0, nil
      for _, el in ipairs(sec.Elements or {}) do
        if el.Type == "Dropdown" and el.IsOpen and el.HeaderY then
          local popH = #(el.Options or {}) * 18 + 4
          openPopY1 = el.HeaderY + 18
          openPopY2 = openPopY1 + popH
          openEl = el
          break
        end
      end
      local elemY = secY + 28 - sec.ScrollY
      for _, el in ipairs(sec.Elements or {}) do
        if el.IsHidden then
          if el.Type == "Slider" then
            if el.LabelTxt then el.LabelTxt.Visible = false end
            if el.ValTxt then el.ValTxt.Visible = false end
            if el.Box then el.Box.Visible = false end
            if el.Border then el.Border.Visible = false end
            if el.Fill then el.Fill.Visible = false end
          elseif el.Type == "Button" or el.Type == "Input" or el.Type == "Dropdown" then
            if el.Box then el.Box.Visible = false end
            if el.Border then el.Border.Visible = false end
            if el.Txt then el.Txt.Visible = false end
          elseif el.Type == "Toggle" then
            if el.Box then el.Box.Visible = false end
            if el.Fill then el.Fill.Visible = false end
            if el.Txt then el.Txt.Visible = false end
          elseif el.Type == "Label" then
            if el.Txt then el.Txt.Visible = false end
          end
        else
          local itemH = 20
          if el.Type == "Button" then itemH = UIDebug.BtnHeight
          elseif el.Type == "Toggle" then itemH = 16
          elseif el.Type == "Label" then itemH = 14
          elseif el.Type == "Input" then itemH = 17
          elseif el.Type == "Slider" then itemH = 22
          elseif el.Type == "Dropdown" then itemH = 17
          end
          local isClipped = (elemY < (secY + 18)) or (elemY >= (secY + secH - 4))
          local isCovered = isClipped or (openEl and el ~= openEl and elemY >= (openPopY1 - 8) and elemY <= (openPopY2 + 4))
        if el.Type == "Button" then
          if isCovered then
            el.Box.Visible = false; el.Border.Visible = false; el.Txt.Visible = false
          else
            el.Box.Color = Colors.ButtonBg; el.Box.Position = Vector2.new(secX + 8, elemY); el.Box.Size = Vector2.new(colW - 16, UIDebug.BtnHeight); el.Box.Visible = true
            el.Border.Color = Colors.ButtonBorder; el.Border.Position = Vector2.new(secX + 8, elemY); el.Border.Size = Vector2.new(colW - 16, UIDebug.BtnHeight); el.Border.Visible = true
            el.Txt.Color = Colors.Text; el.Txt.Font = UIDebug.FontType; el.Txt.Size = UIDebug.BtnTextSize; el.Txt.Position = Vector2.new(secX + math.floor(colW / 2), elemY + UIDebug.BtnTextYOffset); el.Txt.Visible = true
          end
          elemY = elemY + UIDebug.BtnHeight + 4
        elseif el.Type == "Toggle" then
          local boxSz = UIDebug.ToggleBoxSize or 10
          local fillSz = math.max(2, boxSz - 4)
          local fillOff = math.floor((boxSz - fillSz) / 2)
          if isCovered then
            el.Box.Visible = false; el.Fill.Visible = false; el.Txt.Visible = false
          else
            el.Box.Color = Colors.CheckBorder; el.Box.Position = Vector2.new(secX + 8, elemY + 1); el.Box.Size = Vector2.new(boxSz, boxSz); el.Box.Visible = true
            el.Fill.Color = Colors.CheckActive; el.Fill.Position = Vector2.new(secX + 8 + fillOff, elemY + 1 + fillOff); el.Fill.Size = Vector2.new(fillSz, fillSz); el.Fill.Visible = el.State
            el.Txt.Color = Colors.Text; el.Txt.Font = UIDebug.FontType; el.Txt.Size = UIDebug.ToggleTextSize
            el.Txt.Position = Vector2.new(secX + (UIDebug.ToggleTextXOffset or 25), elemY + (UIDebug.ToggleTextYOffset or 0)); el.Txt.Visible = true
          end
          elemY = elemY + math.max(16, boxSz + 4)
        elseif el.Type == "Label" then
          if isCovered then
            el.Txt.Visible = false
          else
            el.Txt.Font = UIDebug.FontType
            if el.IsAccent then
              el.Txt.Color = Colors.Accent
            elseif el.Color then
              el.Txt.Color = el.Color
            else
              el.Txt.Color = Colors.TextDim
            end
            el.Txt.Position = Vector2.new(secX + math.floor(colW / 2), elemY); el.Txt.Visible = true
          end
          elemY = elemY + 14
        elseif el.Type == "Input" then
          if isCovered then
            el.Box.Visible = false; el.Border.Visible = false; el.Txt.Visible = false
          else
            el.Box.Color = Colors.InputBg; el.Box.Position = Vector2.new(secX + 8, elemY); el.Box.Size = Vector2.new(colW - 16, 17); el.Box.Visible = true
            el.Border.Position = Vector2.new(secX + 8, elemY); el.Border.Size = Vector2.new(colW - 16, 17); el.Border.Visible = true
            if UIState.FocusedInput == el then
              el.Border.Color = Colors.Accent
            else
              el.Border.Color = Colors.CheckBorder
            end
            el.Txt.Font = UIDebug.FontType
            el.Txt.Size = UIDebug.InputTextSize
            el.Txt.Center = true
            local displayStr = (el.Value ~= "" and el.Value) or el.Placeholder
            if UIState.FocusedInput == el then displayStr = displayStr .. "_" end
            if #displayStr > 32 then displayStr = displayStr:sub(1, 29) .. "..." end
            el.Txt.Text = displayStr
            el.Txt.Color = (el.Value ~= "" and Colors.Text) or Colors.TextDim
            el.Txt.Position = Vector2.new(secX + math.floor(colW / 2), elemY + UIDebug.InputTextYOffset); el.Txt.Visible = true
          end
          elemY = elemY + 20
        elseif el.Type == "Slider" then
          if isCovered then
            el.LabelTxt.Visible = false; el.ValTxt.Visible = false; el.Box.Visible = false; el.Border.Visible = false; el.Fill.Visible = false
          else
            local barW = colW - 16
            el.LabelTxt.Color = Colors.Text; el.LabelTxt.Font = UIDebug.FontType
            el.LabelTxt.Position = Vector2.new(secX + 8, elemY)
            el.LabelTxt.Visible = true
            el.ValTxt.Color = Colors.Accent; el.ValTxt.Font = UIDebug.FontType
            local fmtStr = (el.Decimals and el.Decimals > 0) and ("%." .. el.Decimals .. "f") or "%d"
            el.ValTxt.Text = string.format(fmtStr, el.Value)
            el.ValTxt.Position = Vector2.new(secX + colW - 35, elemY)
            el.ValTxt.Visible = true
            local barY = elemY + 13
            el.Box.Color = Colors.InputBg; el.Box.Position = Vector2.new(secX + 8, barY); el.Box.Size = Vector2.new(barW, 5); el.Box.Visible = true
            el.Border.Color = Colors.ButtonBorder; el.Border.Position = Vector2.new(secX + 8, barY); el.Border.Size = Vector2.new(barW, 5); el.Border.Visible = true
            local pct = (el.Value - el.Min) / (el.Max - el.Min)
            local fillW = math.clamp(math.floor(barW * pct), 0, barW)
            el.Fill.Color = Colors.Accent; el.Fill.Position = Vector2.new(secX + 8, barY); el.Fill.Size = Vector2.new(fillW, 5); el.Fill.Visible = true
            el.TrackX = secX + 8
            el.TrackW = barW
          end
          elemY = elemY + 22
        elseif el.Type == "Dropdown" then
          el.HeaderY = elemY
          if isCovered then
            el.Box.Visible = false; el.Border.Visible = false; el.Txt.Visible = false
            if el.PopupBg then el.PopupBg.Visible = false end
            if el.PopupBorder then el.PopupBorder.Visible = false end
            for _, optItem in ipairs(el.OptionItems or {}) do
              optItem.Box.Visible = false; optItem.Border.Visible = false; optItem.Txt.Visible = false
            end
          else
            el.Box.Color = Colors.InputBg; el.Box.Position = Vector2.new(secX + 8, elemY); el.Box.Size = Vector2.new(colW - 16, 17); el.Box.Visible = true
            el.Border.Color = Colors.CheckBorder; el.Border.Position = Vector2.new(secX + 8, elemY); el.Border.Size = Vector2.new(colW - 16, 17); el.Border.Visible = true
            el.Txt.Font = UIDebug.FontType
            el.Txt.Size = UIDebug.InputTextSize
            el.Txt.Center = true
            local activeTxt = el.Selected or el.Value or ""
            if el.IsMultiSelect then
              local selectedNames = {}
              local count = 0
              local total = #(el.Options or {})
              for optName, isSel in pairs(el.SelectedMap or {}) do
                if isSel then
                  selectedNames[#selectedNames + 1] = optName
                  count = count + 1
                end
              end
              if count == 0 then
                activeTxt = "None"
              elseif count == total then
                activeTxt = "All Selected"
              else
                activeTxt = table.concat(selectedNames, ", ")
              end
            end
            local headerStr = el.Name .. ": " .. tostring(activeTxt)
            if #headerStr > 28 then
              headerStr = headerStr:sub(1, 26) .. ".."
            end
            el.Txt.Text = headerStr .. (el.IsOpen and " [^]" or " [v]")
            el.Txt.Position = Vector2.new(secX + math.floor(colW / 2), elemY + UIDebug.InputTextYOffset); el.Txt.Visible = true
            if el.IsOpen then
              local popH = #(el.Options or {}) * 18 + 4
              local popY = elemY + 18
              el.PopupBg.Color = Colors.SidebarBg; el.PopupBg.Position = Vector2.new(secX + 8, popY); el.PopupBg.Size = Vector2.new(colW - 16, popH); el.PopupBg.Visible = true
              el.PopupBorder.Color = Colors.Accent; el.PopupBorder.Position = Vector2.new(secX + 8, popY); el.PopupBorder.Size = Vector2.new(colW - 16, popH); el.PopupBorder.Visible = true
              local itemY = popY + 2
              for _, optItem in ipairs(el.OptionItems or {}) do
                local isSelected = false
                if el.IsMultiSelect then
                  isSelected = el.SelectedMap[optItem.Name] == true
                else
                  isSelected = (el.Value == optItem.Name)
                end
                optItem.Box.Position = Vector2.new(secX + 9, itemY)
                optItem.Box.Size = Vector2.new(colW - 18, 16)
                optItem.Box.Color = isSelected and Colors.SelectedBg or Colors.ButtonBg
                optItem.Box.Visible = true
                optItem.Border.Position = Vector2.new(secX + 9, itemY)
                optItem.Border.Size = Vector2.new(colW - 18, 16)
                optItem.Border.Color = isSelected and Colors.Accent or Colors.ButtonBorder
                optItem.Border.Visible = true
                optItem.Txt.Font = UIDebug.FontType
                optItem.Txt.Size = UIDebug.InputTextSize
                optItem.Txt.Center = true
                local itemStr = optItem.Name
                if #itemStr > 28 then
                  itemStr = itemStr:sub(1, 26) .. ".."
                end
                if el.IsMultiSelect then
                  optItem.Txt.Text = (isSelected and "[X] " or "[  ] ") .. itemStr
                else
                  optItem.Txt.Text = itemStr
                end
                optItem.Txt.Color = isSelected and Colors.Accent or Colors.Text
                optItem.Txt.Position = Vector2.new(secX + math.floor(colW / 2), itemY + UIDebug.InputTextYOffset)
                optItem.Txt.Visible = true
                itemY = itemY + 18
              end
            else
              if el.PopupBg then el.PopupBg.Visible = false end
              if el.PopupBorder then el.PopupBorder.Visible = false end
              for _, optItem in ipairs(el.OptionItems or {}) do
                optItem.Box.Visible = false
                optItem.Border.Visible = false
                optItem.Txt.Visible = false
              end
            end
            elemY = elemY + 20
          end
        end
        end
      end
      secX = secX + colW + 4
      if secX > mainX + colW + 4 then
        secX = mainX
        secY = secY + secH + 4
      end
    end
  end
end
local keyCooldowns = {}
local function UpdateSliderValue(slider, mX)
  if not slider.TrackX or not slider.TrackW then return end
  local pct = math.clamp((mX - slider.TrackX) / slider.TrackW, 0, 1)
  local rawVal = slider.Min + (slider.Max - slider.Min) * pct
  if slider.Decimals and slider.Decimals > 0 then
    local mult = 10 ^ slider.Decimals
    rawVal = math.floor(rawVal * mult + 0.5) / mult
  else
    rawVal = math.floor(rawVal + 0.5)
  end
  if slider.Value ~= rawVal then
    slider.Value = rawVal
    if slider.Callback then
      task.spawn(function()
        slider.Callback(rawVal)
      end)
    end
  end
end
local clickTapBuffered = false
local isMouse1Down = false
pcall(function()
  if UserInputService then
    if UserInputService.InputBegan and type(UserInputService.InputBegan.Connect) == "function" then
      UserInputService.InputBegan:Connect(function(inputObj, gpe)
        if inputObj then
          if inputObj.UserInputType == Enum.UserInputType.MouseButton1 then
            clickTapBuffered = true
            isMouse1Down = true
          elseif inputObj.KeyCode == Enum.KeyCode.End then
            UIState.Visible = not UIState.Visible
            uiWasVisible = nil
            print("[Feature Debug]: UI visibility toggled via InputBegan (Visible = " .. tostring(UIState.Visible) .. ")")
          end
        end
      end)
    end
    if UserInputService.InputEnded and type(UserInputService.InputEnded.Connect) == "function" then
      UserInputService.InputEnded:Connect(function(inputObj, gpe)
        if inputObj and inputObj.UserInputType == Enum.UserInputType.MouseButton1 then
          isMouse1Down = false
        end
      end)
    end
    if UserInputService.InputChanged and type(UserInputService.InputChanged.Connect) == "function" then
      UserInputService.InputChanged:Connect(function(inputObj, gpe)
        if UIState.Visible and inputObj and inputObj.UserInputType == Enum.UserInputType.MouseWheel then
          local delta = inputObj.Position.Z
          local mX, mY = 0, 0
          pcall(function()
            if UserInputService and UserInputService.GetMouseLocation then
              local loc = UserInputService:GetMouseLocation()
              mX, mY = loc.X, loc.Y
            end
          end)
          if mX == 0 and mY == 0 and Mouse then
            mX, mY = Mouse.X, Mouse.Y
          end
          local pos = UIState.Position
          local mainX = pos.X + UIDebug.SideWidth + 6
          local mainY = pos.Y + 29
          local colW  = (UIDebug.WindowWidth - UIDebug.SideWidth - 16) / 2
          local rowH  = (UIDebug.WindowHeight - 36) / 2
          local currentTab = LibraryData.Tabs[UIState.ActiveTab]
          if currentTab then
            local secX = mainX
            local secY = mainY
            local secCount = #(currentTab.Sections or {})
            for _, sec in ipairs(currentTab.Sections or {}) do
              local secH = (secCount <= 2) and (rowH * 2 + 4) or rowH
              if IsHover(mX, mY, secX, secY, colW, secH) then
                local maxScroll = math.max(0, (sec.MaxContentH or 0) - (secH - 28))
                sec.ScrollY = math.clamp((sec.ScrollY or 0) - delta * 24, 0, maxScroll)
                break
              end
              secX = secX + colW + 4
              if secX > mainX + colW + 4 then
                secX = mainX
                secY = secY + secH + 4
              end
            end
          end
        end
      end)
    end
  end
end)
local lastEndKeyTime = 0
task.spawn(function()
  while true do
    if checkKey(0x23) then -- End key fallback check
      local now = os.clock()
      if (now - lastEndKeyTime) >= 0.3 then
        lastEndKeyTime = now
        UIState.Visible = not UIState.Visible
        uiWasVisible = nil
        print("[Feature Debug]: UI visibility toggled via checkKey (Visible = " .. tostring(UIState.Visible) .. ")")
      end
    end
    if UIState.FocusedInput then
      local activeInput = UIState.FocusedInput
      local now = os.clock()
      local isCtrl = checkKey(0x11)
      local isShift = checkKey(0x10) or checkKey(0xA0) or checkKey(0xA1)
      if isCtrl and checkKey(0x56) then
        if not keyCooldowns[0x56] or (now - keyCooldowns[0x56]) > 0.25 then
          keyCooldowns[0x56] = now
          local clipText = GetClipboardText()
          if clipText then
            activeInput.Value = clipText
          end
        end
      elseif checkKey(0x08) then -- Backspace
        if not keyCooldowns[0x08] or (now - keyCooldowns[0x08]) > 0.12 then
          keyCooldowns[0x08] = now
          if #activeInput.Value > 0 then
            activeInput.Value = string.sub(activeInput.Value, 1, #activeInput.Value - 1)
          end
        end
      elseif checkKey(0x0D) or checkKey(0x1B) then -- Enter / Escape
        SetFocus(nil)
        task.wait(0.15)
      else
        for vkCode, charStr in pairs(VK_MAP) do
          if checkKey(vkCode) then
            if not keyCooldowns[vkCode] or (now - keyCooldowns[vkCode]) > 0.15 then
              keyCooldowns[vkCode] = now
              local charToAppend = charStr
              if isShift then
                if SHIFT_MAP[charStr] then
                  charToAppend = SHIFT_MAP[charStr]
                else
                  charToAppend = charStr:upper()
                end
              end
              activeInput.Value = activeInput.Value .. charToAppend
            end
          else
            keyCooldowns[vkCode] = nil
          end
        end
      end
    end
    if UIState.Visible and not UIState.FocusedInput then
      local isUp = checkKey(0x26) or checkKey(0x21)
      local isDown = checkKey(0x28) or checkKey(0x22)
      if isUp or isDown then
        local now = os.clock()
        if not keyCooldowns[0x26] or (now - keyCooldowns[0x26]) > 0.1 then
          keyCooldowns[0x26] = now
          local currentTab = LibraryData.Tabs[UIState.ActiveTab]
          if currentTab then
            for _, sec in ipairs(currentTab.Sections or {}) do
              local maxScroll = math.max(0, (sec.MaxContentH or 0) - 256)
              if maxScroll > 0 then
                sec.ScrollY = math.clamp((sec.ScrollY or 0) + (isUp and -30 or 30), 0, maxScroll)
              end
            end
          end
        end
      end
    end
    if UIState.Visible then
      local mX, mY = 0, 0
      pcall(function()
        if UserInputService and UserInputService.GetMouseLocation then
          local loc = UserInputService:GetMouseLocation()
          mX = loc.X
          mY = loc.Y
        end
      end)
      if mX == 0 and mY == 0 and Mouse then
        mX = Mouse.X
        mY = Mouse.Y
      end
      mY = mY + (UIDebug.MouseYOffset or 0)
      local isMouseDown = isMouse1Down or (type(ismouse1pressed) == "function" and ismouse1pressed()) or clickTapBuffered
      if isMouseDown then clickTapBuffered = false end
      if isMouseDown then
        if UIState.ActiveSlider then
          UpdateSliderValue(UIState.ActiveSlider, mX)
        elseif UIState.ActiveScrollSec then
          local sec = UIState.ActiveScrollSec
          local pos = UIState.Position
          local secH = 284
          local maxScroll = math.max(0, (sec.MaxContentH or 0) - (secH - 26))
          local pct = math.clamp((mY - (pos.Y + 47)) / (secH - 22), 0, 1)
          sec.ScrollY = math.floor(pct * maxScroll)
        end
      else
        UIState.ActiveSlider = nil
        UIState.ActiveScrollSec = nil
      end
      if isMouseDown and not UIState.LastClick then
        if IsHover(mX, mY, UIState.Position.X, UIState.Position.Y, UIDebug.WindowWidth, 24) then
          UIState.Dragging = true
          UIState.DragOffset = Vector2.new(mX - UIState.Position.X, mY - UIState.Position.Y)
        end
      end
      if not isMouseDown then
        UIState.Dragging = false
      end
      if UIState.Dragging then
        UIState.Position = Vector2.new(mX - UIState.DragOffset.X, mY - UIState.DragOffset.Y)
      end
      if isMouseDown and not UIState.LastClick and not UIState.Dragging then
        local pos = UIState.Position
        local tY = pos.Y + 34
        local allTabs = LibraryData.TabOrder
        for _, tabName in ipairs(allTabs) do
          if tabName ~= "Settings" and tabName ~= "Config" then
            if IsHover(mX, mY, pos.X, tY, UIDebug.SideWidth, 30) then
              UIState.ActiveTab = tabName
            end
            tY = tY + 34
          end
        end
        local configY = pos.Y + UIDebug.WindowHeight - 48
        if IsHover(mX, mY, pos.X + 6, configY, UIDebug.SideWidth - 12, 18) then
          UIState.ActiveTab = "Config"
        end
        local settingsY = pos.Y + UIDebug.WindowHeight - 26
        if IsHover(mX, mY, pos.X + 6, settingsY, UIDebug.SideWidth - 12, 18) then
          UIState.ActiveTab = "Settings"
        end
        local mainX = pos.X + UIDebug.SideWidth + 6
        local mainY = pos.Y + 29
        local colW  = (UIDebug.WindowWidth - UIDebug.SideWidth - 16) / 2
        local rowH  = (UIDebug.WindowHeight - 36) / 2
        local clickedAnyInput = false
        local currentTab = LibraryData.Tabs[UIState.ActiveTab]
        if currentTab then
          local secX = mainX
          local secY = mainY
          local secCount = #(currentTab.Sections or {})
          for _, sec in ipairs(currentTab.Sections or {}) do
            local secH = (secCount <= 2) and (rowH * 2 + 4) or rowH
            local maxScroll = math.max(0, (sec.MaxContentH or 0) - (secH - 32))
            local elemY = secY + 28 - (sec.ScrollY or 0)
            local clickedOverlay = false
            if maxScroll > 0 then
              if IsHover(mX, mY, secX + colW - 36, secY, 16, 16) then
                clickedOverlay = true
                local now = os.clock()
                if not sec.LastScrollClick or (now - sec.LastScrollClick) >= 0.05 then
                  sec.LastScrollClick = now
                  sec.ScrollY = math.clamp((sec.ScrollY or 0) - 25, 0, maxScroll)
                end
              elseif IsHover(mX, mY, secX + colW - 18, secY, 16, 16) then
                clickedOverlay = true
                local now = os.clock()
                if not sec.LastScrollClick or (now - sec.LastScrollClick) >= 0.05 then
                  sec.LastScrollClick = now
                  sec.ScrollY = math.clamp((sec.ScrollY or 0) + 25, 0, maxScroll)
                end
              elseif IsHover(mX, mY, secX + colW - 14, secY + 22, 14, secH - 22) then
                clickedOverlay = true
                UIState.ActiveScrollSec = sec
                local pct = math.clamp((mY - (secY + 22)) / (secH - 26), 0, 1)
                sec.ScrollY = math.floor(pct * maxScroll)
              end
            end
            for _, el in ipairs(sec.Elements or {}) do
              if el.Type == "Dropdown" and el.IsOpen and el.HeaderY then
                local optionY = el.HeaderY + 18
                local numOpts = #(el.OptionItems or {})
                local popH = math.max(18, numOpts * 18 + 2)
                if IsHover(mX, mY, secX + 8, optionY, colW - 16, popH) then
                  clickedOverlay = true
                  UIState.ActiveSlider = nil
                  for idx, optItem in ipairs(el.OptionItems or {}) do
                    local itemY = optionY + 1 + (idx - 1) * 18
                    if IsHover(mX, mY, secX + 9, itemY, colW - 18, 16) then
                      local now = os.clock()
                      if not el.LastClick or (now - el.LastClick) >= 0.05 then
                        el.LastClick = now
                        if el.IsMultiSelect then
                          el.SelectedMap = el.SelectedMap or {}
                          local newState = not el.SelectedMap[optItem.Name]
                          el.SelectedMap[optItem.Name] = newState
                          if el.Callback then
                            local optN = optItem.Name
                            local mapCopy = el.SelectedMap
                            task.spawn(function() el.Callback(optN, newState, mapCopy) end)
                          end
                        else
                          el.Selected = optItem.Name
                          el.Value = optItem.Name
                          el.IsOpen = false
                          if el.Callback then
                            local sel = optItem.Name
                            task.spawn(function() el.Callback(sel) end)
                          end
                        end
                      end
                      break
                    end
                  end
                  break
                end
              end
            end
            if not clickedOverlay then
              for _, el in ipairs(sec.Elements or {}) do
                if not el.IsHidden then
                  local itemH = 20
                  if el.Type == "Button" then itemH = UIDebug.BtnHeight
                  elseif el.Type == "Toggle" then itemH = 16
                  elseif el.Type == "Label" then itemH = 14
                  elseif el.Type == "Input" then itemH = 17
                  elseif el.Type == "Slider" then itemH = 22
                  elseif el.Type == "Dropdown" then itemH = 17
                  end
                local isVisibleInFrame = (elemY >= (secY + 18)) and (elemY < (secY + secH - 4))
                if el.Type == "Button" then
                  if isVisibleInFrame and IsHover(mX, mY, secX + 8, elemY, colW - 16, UIDebug.BtnHeight) then
                    local now = os.clock()
                    if not el.LastClick or (now - el.LastClick) >= 0.05 then
                      el.LastClick = now
                      if el.Callback then
                        task.spawn(el.Callback)
                      end
                    end
                  end
                  elemY = elemY + UIDebug.BtnHeight + 4
                elseif el.Type == "Toggle" then
                  if isVisibleInFrame and IsHover(mX, mY, secX + 8, elemY, colW - 16, 16) then
                    local now = os.clock()
                    if not el.LastClick or (now - el.LastClick) >= 0.05 then
                      el.LastClick = now
                      el.State = not el.State
                      if el.Callback then
                        local state = el.State
                        task.spawn(function()
                          el.Callback(state)
                        end)
                      end
                    end
                  end
                  elemY = elemY + 16
                elseif el.Type == "Label" then
                  elemY = elemY + 14
                elseif el.Type == "Input" then
                  if isVisibleInFrame and IsHover(mX, mY, secX + 8, elemY, colW - 16, 17) then
                    clickedAnyInput = true
                    SetFocus(el)
                    local clipText = GetClipboardText()
                    if clipText and (clipText:lower():find("http") or clipText:lower():find("discord")) then
                      el.Value = clipText
                    end
                  end
                  elemY = elemY + 20
                elseif el.Type == "Slider" then
                  if isVisibleInFrame and IsHover(mX, mY, secX + 8, elemY, colW - 16, 22) then
                    UIState.ActiveSlider = el
                    UpdateSliderValue(el, mX)
                  end
                  elemY = elemY + 22
                elseif el.Type == "Dropdown" then
                  local headerY = elemY
                  if isVisibleInFrame and IsHover(mX, mY, secX + 8, headerY, colW - 16, 17) then
                    local now = os.clock()
                    if not el.LastClick or (now - el.LastClick) >= 0.05 then
                      el.LastClick = now
                      el.IsOpen = not el.IsOpen
                    end
                  end
                  elemY = elemY + 20
                end
                end
              end
            end
            secX = secX + colW + 4
            if secX > mainX + colW + 4 then
              secX = mainX
              secY = secY + secH + 4
            end
          end
        end
        if not clickedAnyInput then
          SetFocus(nil)
        end
      end
      UIState.LastClick = isMouseDown
    end
    RenderUI()
    if UIState.ActiveSlider or UIState.Dragging then
      task.wait(0.016)
    elseif UIState.Visible then
      task.wait(0.04)
    else
      task.wait(0.15)
    end
  end
end)
local SectionAPI = {}
function SectionAPI.CreateButton(secData, name, callback)
  local btnObj = {
    Type = "Button",
    Name = name,
    Callback = callback,
    Box = createDraw("Square", { Filled = true, Color = Colors.ButtonBg, ZIndex = 3 }),
    Border = createDraw("Square", { Filled = false, Color = Colors.ButtonBorder, Thickness = 1, ZIndex = 4 }),
    Txt = createDraw("Text", { Text = name, Size = UIDebug.BtnTextSize, Color = Colors.Text, Center = true, Font = Drawing.Fonts.Plex, ZIndex = 5 })
  }
  secData.Elements[#secData.Elements + 1] = btnObj
  return {
    SetText = function(_, newText)
      btnObj.Name = newText
      btnObj.Txt.Text = newText
    end
  }
end

function SectionAPI.CreateDropdown(secData, name, options, defaultVal, callback)
  local selected = defaultVal or (options and options[1]) or ""
  local dropObj = {
    Type = "Dropdown",
    Name = name,
    Options = options or {},
    Selected = selected,
    Value = selected,
    IsOpen = false,
    Callback = callback,
    Box = createDraw("Square", { Filled = true, Color = Colors.InputBg, ZIndex = 6 }),
    Border = createDraw("Square", { Filled = false, Color = Colors.CheckBorder, Thickness = 1, ZIndex = 7 }),
    Txt = createDraw("Text", { Text = name .. ": " .. selected .. " [v]", Size = UIDebug.InputTextSize, Color = Colors.Text, Center = true, Font = Drawing.Fonts.Plex, ZIndex = 8 }),
    PopupBg = createDraw("Square", { Filled = true, Color = Colors.SidebarBg, Visible = false, ZIndex = 20 }),
    PopupBorder = createDraw("Square", { Filled = false, Color = Colors.Accent, Thickness = 1, Visible = false, ZIndex = 21 }),
    OptionItems = {}
  }
  for i, opt in ipairs(options or {}) do
    dropObj.OptionItems[#dropObj.OptionItems + 1] = {
      Name = opt,
      Box = createDraw("Square", { Filled = true, Color = Colors.ButtonBg, Visible = false, ZIndex = 22 }),
      Border = createDraw("Square", { Filled = false, Color = Colors.ButtonBorder, Thickness = 1, Visible = false, ZIndex = 23 }),
      Txt = createDraw("Text", { Text = opt, Size = UIDebug.InputTextSize, Color = Colors.Text, Center = true, Font = Drawing.Fonts.Plex, Visible = false, ZIndex = 24 })
    }
  end
  secData.Elements[#secData.Elements + 1] = dropObj
  return {
    SetSelected = function(_, newSel)
      dropObj.Selected = newSel
      dropObj.Value = newSel
      dropObj.Txt.Text = dropObj.Name .. ": " .. newSel .. (dropObj.IsOpen and " [^]" or " [v]")
    end,
    UpdateOptions = function(_, newOptions, newSelected)
      for _, item in ipairs(dropObj.OptionItems or {}) do
        pcall(function()
          if item.Box then item.Box:Remove() end
          if item.Border then item.Border:Remove() end
          if item.Txt then item.Txt:Remove() end
        end)
      end
      dropObj.Options = newOptions or {}
      dropObj.OptionItems = {}
      for i, opt in ipairs(dropObj.Options) do
        dropObj.OptionItems[#dropObj.OptionItems + 1] = {
          Name = opt,
          Box = createDraw("Square", { Filled = true, Color = Colors.ButtonBg, Visible = false, ZIndex = 22 }),
          Border = createDraw("Square", { Filled = false, Color = Colors.ButtonBorder, Thickness = 1, Visible = false, ZIndex = 23 }),
          Txt = createDraw("Text", { Text = opt, Size = UIDebug.InputTextSize, Color = Colors.Text, Center = true, Font = Drawing.Fonts.Plex, Visible = false, ZIndex = 24 })
        }
      end
      local sel = newSelected or dropObj.Options[1] or ""
      dropObj.Selected = sel
      dropObj.Value = sel
      dropObj.Txt.Text = dropObj.Name .. ": " .. sel .. (dropObj.IsOpen and " [^]" or " [v]")
    end
  }
end

function SectionAPI.CreateMultiSelect(secData, name, options, defaultSelectedMap, callback)
  local selectedMap = {}
  for _, opt in ipairs(options or {}) do
    if defaultSelectedMap and defaultSelectedMap[opt] ~= nil then
      selectedMap[opt] = defaultSelectedMap[opt]
    else
      selectedMap[opt] = true
    end
  end
  local function getSummary()
    local active = {}
    for _, opt in ipairs(options or {}) do
      if selectedMap[opt] then active[#active + 1] = opt end
    end
    if #active == 0 then return "None" end
    if #active == #(options or {}) then return "All Selected" end
    return table.concat(active, ", ")
  end
  local dropObj = {
    Type = "Dropdown",
    IsMultiSelect = true,
    Name = name,
    Options = options or {},
    SelectedMap = selectedMap,
    IsOpen = false,
    Callback = callback,
    Box = createDraw("Square", { Filled = true, Color = Colors.InputBg, ZIndex = 6 }),
    Border = createDraw("Square", { Filled = false, Color = Colors.CheckBorder, Thickness = 1, ZIndex = 7 }),
    Txt = createDraw("Text", { Text = name .. ": " .. getSummary() .. " [v]", Size = UIDebug.InputTextSize, Color = Colors.Text, Center = true, Font = Drawing.Fonts.Plex, ZIndex = 8 }),
    PopupBg = createDraw("Square", { Filled = true, Color = Colors.SidebarBg, Visible = false, ZIndex = 20 }),
    PopupBorder = createDraw("Square", { Filled = false, Color = Colors.Accent, Thickness = 1, Visible = false, ZIndex = 21 }),
    OptionItems = {}
  }
  for i, opt in ipairs(options or {}) do
    dropObj.OptionItems[#dropObj.OptionItems + 1] = {
      Name = opt,
      Box = createDraw("Square", { Filled = true, Color = Colors.ButtonBg, Visible = false, ZIndex = 22 }),
      Border = createDraw("Square", { Filled = false, Color = Colors.ButtonBorder, Thickness = 1, Visible = false, ZIndex = 23 }),
      Txt = createDraw("Text", { Text = opt, Size = UIDebug.InputTextSize, Color = Colors.Text, Center = true, Font = Drawing.Fonts.Plex, Visible = false, ZIndex = 24 })
    }
  end
  secData.Elements[#secData.Elements + 1] = dropObj
  return dropObj
end

function SectionAPI.CreateToggle(secData, name, defaultState, callback)
  secData.Elements[#secData.Elements + 1] = {
    Type = "Toggle",
    Name = name,
    State = defaultState or false,
    Callback = callback,
    Box = createDraw("Square", { Filled = false, Color = Colors.CheckBorder, Thickness = 1, ZIndex = 3 }),
    Fill = createDraw("Square", { Filled = true, Color = Colors.CheckActive, Visible = false, ZIndex = 4 }),
    Txt = createDraw("Text", { Text = name, Size = UIDebug.ToggleTextSize, Color = Colors.Text, Font = Drawing.Fonts.Plex, ZIndex = 3 })
  }
end

function SectionAPI.CreateLabel(secData, text, color)
  local lblObj = {
    Type = "Label",
    Name = text,
    Color = color,
    IsAccent = (color == Colors.Accent),
    Txt = createDraw("Text", { Text = text, Size = 11, Color = color or Colors.TextDim, Center = true, Font = Drawing.Fonts.Plex, ZIndex = 3 })
  }
  secData.Elements[#secData.Elements + 1] = lblObj
  return {
    SetText = function(_, newText)
      lblObj.Txt.Text = newText
    end,
    SetColor = function(_, newColor)
      lblObj.Color = newColor
      lblObj.IsAccent = (newColor == Colors.Accent)
      lblObj.Txt.Color = newColor
    end
  }
end

function SectionAPI.CreateInput(secData, placeholder, defaultText, callback)
  if type(defaultText) == "function" then
    callback = defaultText
    defaultText = ""
  end
  local inpObj = {
    Type = "Input",
    Placeholder = placeholder or "Enter text...",
    Value = defaultText or "",
    Callback = callback,
    Box = createDraw("Square", { Filled = true, Color = Colors.InputBg, ZIndex = 3 }),
    Border = createDraw("Square", { Filled = false, Color = Colors.CheckBorder, Thickness = 1, ZIndex = 4 }),
    Txt = createDraw("Text", { Text = placeholder or "Enter text...", Size = 11, Color = Colors.TextDim, Center = true, Font = Drawing.Fonts.Plex, ZIndex = 5 })
  }
  secData.Elements[#secData.Elements + 1] = inpObj
  return inpObj
end

function SectionAPI.CreateSlider(secData, name, min, max, default, decimals, callback)
  if type(decimals) == "function" then
    callback = decimals
    decimals = 0
  end
  local sldObj = {
    Type = "Slider",
    Name = name,
    Min = min or 0,
    Max = max or 100,
    Value = default or min or 0,
    Decimals = decimals or 0,
    Callback = callback,
    LabelTxt = createDraw("Text", { Text = name, Size = 11, Color = Colors.Text, Font = Drawing.Fonts.Plex, ZIndex = 3 }),
    ValTxt = createDraw("Text", { Text = tostring(default or min or 0), Size = 11, Color = Colors.Accent, Font = Drawing.Fonts.Plex, ZIndex = 3 }),
    Box = createDraw("Square", { Filled = true, Color = Colors.InputBg, ZIndex = 3 }),
    Border = createDraw("Square", { Filled = false, Color = Colors.ButtonBorder, Thickness = 1, ZIndex = 4 }),
    Fill = createDraw("Square", { Filled = true, Color = Colors.Accent, ZIndex = 5 })
  }
  secData.Elements[#secData.Elements + 1] = sldObj
  return sldObj
end

do
  local function CreateWindow(config)
    config = config or {}
    UIDebug.WindowWidth = config.Width or UIDebug.WindowWidth
    UIDebug.WindowHeight = config.Height or UIDebug.WindowHeight
    if config.Title then headerText.Text = config.Title end
    return {
      CreateTab = function(_, tabName)
        local tabData = {
          Name = tabName,
          DrawText = createDraw("Text", { Text = tabName, Size = 13, Font = Drawing.Fonts.Plex, ZIndex = 3 }),
          Sections = {}
        }
        LibraryData.Tabs[tabName] = tabData
        LibraryData.TabOrder[#LibraryData.TabOrder + 1] = tabName
        return {
          CreateSection = function(_, secTitle)
            local secData = {
              Title = secTitle,
              Box = createDraw("Square", { Filled = true, Color = Colors.BoxBg, ZIndex = 2 }),
              Border = createDraw("Square", { Filled = false, Color = Colors.ButtonBorder, Thickness = 1, ZIndex = 3 }),
              HeaderLine = createDraw("Line", { Color = Colors.Accent, Thickness = 1, ZIndex = 3 }),
              TitleText = createDraw("Text", { Text = secTitle, Size = 12, Color = Colors.Accent, Center = true, Font = Drawing.Fonts.Plex, ZIndex = 4 }),
              ScrollTrack = createDraw("Square", { Filled = true, Color = Colors.ButtonBg, Visible = false, ZIndex = 15 }),
              ScrollThumb = createDraw("Square", { Filled = true, Color = Colors.Accent, Visible = false, ZIndex = 16 }),
              ScrollUpBtn = createDraw("Text", { Text = "[^]", Size = 11, Color = Colors.Accent, Font = Drawing.Fonts.Plex, Visible = false, ZIndex = 17 }),
              ScrollDownBtn = createDraw("Text", { Text = "[v]", Size = 11, Color = Colors.Accent, Font = Drawing.Fonts.Plex, Visible = false, ZIndex = 17 }),
              ScrollY = 0,
              MaxContentH = 0,
              Elements = {}
            }
            tabData.Sections[#tabData.Sections + 1] = secData
            return {
              CreateButton = function(_, name, cb) return SectionAPI.CreateButton(secData, name, cb) end,
              CreateDropdown = function(_, name, opts, def, cb) return SectionAPI.CreateDropdown(secData, name, opts, def, cb) end,
              CreateMultiSelect = function(_, name, opts, defMap, cb) return SectionAPI.CreateMultiSelect(secData, name, opts, defMap, cb) end,
              CreateToggle = function(_, name, defState, cb) return SectionAPI.CreateToggle(secData, name, defState, cb) end,
              CreateLabel = function(_, text, col) return SectionAPI.CreateLabel(secData, text, col) end,
              CreateInput = function(_, ph, defText, cb) return SectionAPI.CreateInput(secData, ph, defText, cb) end,
              CreateSlider = function(_, name, min, max, def, dec, cb) return SectionAPI.CreateSlider(secData, name, min, max, def, dec, cb) end
            }
          end
        }
      end
    }
  end
  LibraryData.Window = CreateWindow({
    Title = "One Protocol 8.8.26_2beta - Matcha Edition",
    Width = 600,
    Height = 320
  })
end
local UI_BUILDERS = {}
function UI_BUILDERS.buildInfoTab()
  local Window = LibraryData.Window
  local InfoTab = Window:CreateTab("Info")
  local UpdatesSec = InfoTab:CreateSection("Script Capabilities")
  UpdatesSec:CreateLabel("One Protocol 8.8.26_2beta - Matcha Edition", Colors.Accent)
  UpdatesSec:CreateLabel("- Engine: Matcha External LuaVM")
  UpdatesSec:CreateLabel("- Toggle GUI: Press [End] key")
  UpdatesSec:CreateLabel("- Webhook Input: Click to focus & paste")
  UpdatesSec:CreateLabel("- Anti Fling: Legit & Rage modes")
  UpdatesSec:CreateLabel("- Panic Mode: Auto-Evade & Zone Circle")
  UpdatesSec:CreateLabel("- AutoFarm: Coins, XP & Discord Webhooks")
  UpdatesSec:CreateLabel("- Defense: Instant Force Respawn")
  local MatchSec = InfoTab:CreateSection("Live Match Status")
  LibraryData.StatusLabels.Murd = MatchSec:CreateLabel("- Murderer: Searching...", Colors.TextDim)
  LibraryData.StatusLabels.Sheriff = MatchSec:CreateLabel("- Sheriff: Searching...", Colors.TextDim)
  LibraryData.StatusLabels.GunDrop = MatchSec:CreateLabel("- Gun Dropped: NO", Colors.Red)
  LibraryData.StatusLabels.SessionCoins = MatchSec:CreateLabel("- Session Coins: 0 / " .. tostring(FarmStats.MaxCoins or 40), Colors.TextActive)
  LibraryData.StatusLabels.AllTimeCoins = MatchSec:CreateLabel("- All-Time Coins: " .. tostring(FarmStats.TotalCoinsAllTime or 0), Colors.Accent)
end

task.spawn(function()
  while true do
    pcall(function()
      local lbls = LibraryData.StatusLabels
      if lbls then
        if lbls.Murd and lbls.Murd.SetText then
          if espFoundMurd and #espFoundMurd > 0 then
            lbls.Murd:SetText("- Murderer: " .. espFoundMurd)
            lbls.Murd:SetColor(Colors.Red)
          else
            lbls.Murd:SetText("- Murderer: Searching...")
            lbls.Murd:SetColor(Colors.TextDim)
          end
        end
        if lbls.Sheriff and lbls.Sheriff.SetText then
          if espFoundSheriff and #espFoundSheriff > 0 then
            lbls.Sheriff:SetText("- Sheriff: " .. espFoundSheriff)
            lbls.Sheriff:SetColor(Colors.Blue)
          else
            lbls.Sheriff:SetText("- Sheriff: Searching...")
            lbls.Sheriff:SetColor(Colors.TextDim)
          end
        end
        if lbls.GunDrop and lbls.GunDrop.SetText then
          local hasGun = (gunDropTargets and #gunDropTargets > 0)
          if hasGun then
            lbls.GunDrop:SetText("- Gun Dropped: YES!")
            lbls.GunDrop:SetColor(Color3.fromRGB(255, 220, 0))
          else
            lbls.GunDrop:SetText("- Gun Dropped: NO")
            lbls.GunDrop:SetColor(Colors.Red)
          end
        end
        if lbls.SessionCoins and lbls.SessionCoins.SetText then
          lbls.SessionCoins:SetText("- Session Coins: " .. tostring(FarmStats.SessionCoins or 0) .. " / " .. tostring(FarmStats.MaxCoins or 50))
        end
        if lbls.AllTimeCoins and lbls.AllTimeCoins.SetText then
          lbls.AllTimeCoins:SetText("- All-Time Coins: " .. tostring(FarmStats.TotalCoinsAllTime or 0))
        end
      end
    end)
    task.wait(0.5)
  end
end)

function UI_BUILDERS.buildAutoFarmTab()
  local Window = LibraryData.Window
  local AutoFarmTab = Window:CreateTab("AutoFarm")
  local AutoFarmSec1 = AutoFarmTab:CreateSection("Auto Farm Configuration")
  AutoFarmSec1:CreateToggle("Enable Auto Farm", false, function(state)
    AutoFarmState.Enabled = state
    if state then
      if AutoFarmState.Method == "Undermap" then
        local safePos = Vector3.new(1.94, -97.21, 15.65)
        setPosAndLook(safePos, nil)
      end
    else
      firstpos = nil
      firstcframe = nil
      first = true
      pcall(function()
        local plr = LocalPlayer
        local char = plr and plr.Character
        if char then
          for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
              part.CanCollide = true
            end
          end
        end
      end)
    end
  end)
  local flightSpeedSlider = nil
  local teleportCooldownSlider = nil
  AutoFarmSec1:CreateDropdown("Farm Method", { "Normal", "Undermap", "Teleport" }, "Normal", function(method)
    AutoFarmState.Method = method
    if method == "Undermap" and AutoFarmState.Enabled then
      local safePos = Vector3.new(1.94, -97.21, 15.65)
      setPosAndLook(safePos, nil)
    end
    if flightSpeedSlider and teleportCooldownSlider then
      if method == "Teleport" then
        flightSpeedSlider.IsHidden = true
        teleportCooldownSlider.IsHidden = false
      else
        flightSpeedSlider.IsHidden = false
        teleportCooldownSlider.IsHidden = true
      end
    end
  end)
  flightSpeedSlider = AutoFarmSec1:CreateSlider("Flight Speed", 10, 150, 25, 0, function(val)
    AutoFarmState.UndermapSpeed = val
    AutoFarmState.Speed = val
  end)
  teleportCooldownSlider = AutoFarmSec1:CreateSlider("Teleport Cooldown (s)", 0.1, 3.0, 0.3, 1, function(val)
    AutoFarmState.TeleportCooldown = val
  end)
  teleportCooldownSlider.IsHidden = true
  AutoFarmSec1:CreateSlider("Max Coins Limit", 10, 50, 50, 0, function(val)
    AutoFarmState.MaxCoins = val
    FarmStats.MaxCoins = val
  end)
  AutoFarmSec1:CreateDropdown("Full Bag Action", { "Reset / Die", "Stay Under Map" }, "Reset / Die", function(action)
    AutoFarmState.FullBagAction = action
    AutoFarmState.FullBagResetDone = false
  end)
  local SafeSec = AutoFarmTab:CreateSection("Safe Methods & Avoidance")
  SafeSec:CreateToggle("Enable Safe Avoidance", false, function(state)
    AutoFarmState.SafeAvoidEnabled = state
  end)
  SafeSec:CreateDropdown("Avoid Target Filter", { "Murderer Only", "Murderer & Sheriff", "All Players" }, "Murderer & Sheriff", function(targetFilter)
    AutoFarmState.SafeAvoidTarget = targetFilter
  end)
  SafeSec:CreateSlider("Avoid Danger Radius (m)", 5, 50, 20, 0, function(val)
    AutoFarmState.SafeAvoidRadius = val
  end)
  SafeSec:CreateToggle("In-Flight Mid-Route Evade (Smooth Hold)", true, function(state)
    AutoFarmState.SafeMidFlightEvade = state
  end)
  local WebhookSec = AutoFarmTab:CreateSection("Discord Webhook & Logs")
  WebhookSec:CreateToggle("Enable Discord Webhook", FarmStats.WebhookEnabled, function(state)
    FarmStats.WebhookEnabled = state
  end)
  local webhookInput = WebhookSec:CreateInput("Enter Webhook URL...", initialWebhook, function(val)
    _G.Webhook = val
  end)
  WebhookSec:CreateButton("Test Webhook", function()
    local currentVal = webhookInput.Value
    if currentVal == "" then
    else
      _G.Webhook = currentVal
      initialWebhook = currentVal
      task.spawn(function()
        local ok, msg = SendWebhook(currentVal, BuildWebhookMessage())
        if ok then
        else
        end
      end)
    end
  end)
  WebhookSec:CreateSlider("Report Interval (min)", 1, 60, 5, 0, function(val)
    FarmStats.WebhookInterval = val
  end)
end

function UI_BUILDERS.buildMovementTab()
  local Window = LibraryData.Window
  local MovementTab = Window:CreateTab("Movement")
  local RespawnSec = MovementTab:CreateSection("Character Control & Reset")
  RespawnSec:CreateButton("Instant Respawn Character", function()
    forceResetCharacter()
  end)
  local PanicSec = MovementTab:CreateSection("Panic Evade Engine")
  PanicSec:CreateToggle("Enable Panic Evade", false, function(state)
    PanicState.Enabled = state
  end)
  PanicSec:CreateDropdown("Evade Mode", { "Speed Surge (+50%)", "Float (Hover)", "Teleport", "Warning" }, "Speed Surge (+50%)", function(mode)
    PanicState.Mode = mode
  end)
  PanicSec:CreateDropdown("Target Filter", { "Murderer Only", "Murderer & Sheriff", "All Players" }, "All Players", function(filter)
    PanicState.TargetFilter = filter
  end)
  PanicSec:CreateSlider("Evade Distance", 10, 100, 35, 0, function(val)
    PanicState.Distance = val
  end)
  PanicSec:CreateToggle("Draw Zone Circle", true, function(state)
    PanicState.DrawCircle = state
  end)
  local AntiFlingSec = MovementTab:CreateSection("Anti Fling Defense")
  AntiFlingSec:CreateToggle("Anti Fling v1 (idk)", false, function(state)
    setLegitAntiFling(state)
  end)
  AntiFlingSec:CreateToggle("Anti Fling v2 (better)", false, function(state)
    setRageAntiFling(state)
  end)
  AntiFlingSec:CreateSlider("Fling Velocity Cap", 50, 500, 150, 0, function(val)
    AntiFlingState.VelocityCap = val
  end)
  local AntiAfkSec = MovementTab:CreateSection("Anti-AFK Protection")
  AntiAfkSec:CreateToggle("Enable Anti-AFK", false, function(state)
    setAntiAFKEnabled(state)
  end)
  AntiAfkSec:CreateToggle("Show On-Screen Overlay", true, function(state)
    AntiAFKState.ShowOverlay = state
    if not state and antiAfkOverlay then
      antiAfkOverlay:SetVisible(false)
    elseif state and AntiAFKState.Enabled then
      showAntiAfkOverlay()
    end
  end)
  AntiAfkSec:CreateToggle("Hotkey Toggle (Right Ctrl)", true, function(state)
    AntiAFKState.KeybindEnabled = state
  end)
  AntiAfkSec:CreateSlider("AFK Pulse Interval (s)", 15, 300, 60, 0, function(val)
    AntiAFKState.Interval = val
  end)
end

function UI_BUILDERS.buildESPTab()
  local Window = LibraryData.Window
  local ESPTab = Window:CreateTab("ESP")
  local RoleESPSec = ESPTab:CreateSection("Role & Object ESP Settings")
  RoleESPSec:CreateToggle("Master ESP Enable", false, function(state)
    ESPState.Enabled = state
  end)
  RoleESPSec:CreateMultiSelect("ESP Targets", { "Murderer", "Sheriff", "Innocent", "Gun Drop", "Coins" }, {
    ["Murderer"] = true,
    ["Sheriff"] = true,
    ["Innocent"] = true,
    ["Gun Drop"] = true,
    ["Coins"] = true
  }, function(optName, optState, selectedMap)
    if optName == "Murderer" then ESPState.ShowMurderer = optState end
    if optName == "Sheriff" then ESPState.ShowSheriff = optState end
    if optName == "Innocent" then ESPState.ShowInnocent = optState end
    if optName == "Gun Drop" then ESPState.GunDrop = optState end
    if optName == "Coins" then ESPState.Coins = optState end
  end)
  RoleESPSec:CreateToggle("Show 2D Boxes", true, function(state)
    ESPState.Boxes = state
  end)
  RoleESPSec:CreateToggle("Show Player Names", true, function(state)
    ESPState.Names = state
  end)
  RoleESPSec:CreateToggle("Show Distance (m)", true, function(state)
    ESPState.Distance = state
  end)
  RoleESPSec:CreateSlider("Max Render Distance", 50, 1000, 500, 0, function(val)
    ESPState.MaxDistance = val
  end)
  local RoleColorsSec = ESPTab:CreateSection("Role Color Reference")
  RoleColorsSec:CreateLabel("- Murderer: RED (Knife)", Colors.Red)
  RoleColorsSec:CreateLabel("- Sheriff: BLUE (Gun)", Colors.Blue)
  RoleColorsSec:CreateLabel("- Innocent: GREEN", Colors.Green)
  RoleColorsSec:CreateLabel("- Gun Drop: YELLOW", Color3.fromRGB(255, 200, 0))
  RoleColorsSec:CreateLabel("- Coins: GOLD", Color3.fromRGB(255, 220, 0))
end

function UI_BUILDERS.buildTeleportsTab()
  local Window = LibraryData.Window
  local TeleportsTab = Window:CreateTab("Teleports")
  local ActionsSec = TeleportsTab:CreateSection("Match Actions")
  ActionsSec:CreateButton("Grab Gun", function()
    task.spawn(function() grabGunAction() end)
  end)
  ActionsSec:CreateToggle("Auto Grab Gun (Loop)", false, function(state)
    AutoGrabGunEnabled = state
  end)
  ActionsSec:CreateButton("Kill All (Murderer)", function()
    task.spawn(function()
      local me = LocalPlayer and LocalPlayer.Name or ""
      for _, plr in ipairs(Players:GetPlayers()) do
        if plr and plr.Name ~= me and plr.Character then
          local r = plr.Character:FindFirstChild("HumanoidRootPart")
          if r then
            teleportToPos(r.Position)
            task.wait(0.2)
          end
        end
      end
    end)
  end)
  ActionsSec:CreateButton("Instant Force Respawn", function()
    forceResetCharacter()
  end)
  ActionsSec:CreateToggle("Quick Reset Keybind (Press 'R')", false, function(state)
    QuickResetKeybindEnabled = state
  end)
  local TeleportsSec = TeleportsTab:CreateSection("Map & Role Teleports")
  TeleportsSec:CreateButton("Teleport to murderer", function()
    teleportToRolePlayer("Murderer")
  end)
  TeleportsSec:CreateButton("Teleport to sheriff", function()
    teleportToRolePlayer("Sheriff")
  end)
  TeleportsSec:CreateButton("Teleport to map center", function()
    teleportToPos(Vector3.new(0, 50, 0))
  end)
end

function UI_BUILDERS.buildSettingsTab()
  local Window = LibraryData.Window
  local SettingsTab = Window:CreateTab("Settings")
  local SpeedSec = SettingsTab:CreateSection("Speedometer & HUD")
  SpeedSec:CreateToggle("Enable Speedometer", false, function(state)
    SpeedVisState.Enabled = state
  end)
  SpeedSec:CreateToggle("Show Speed Text", true, function(state)
    SpeedVisState.TextEnabled = state
  end)
  SpeedSec:CreateToggle("Show Speed Graph", true, function(state)
    SpeedVisState.GraphEnabled = state
  end)
  local ThemeSec = SettingsTab:CreateSection("UI Theme Engine")
  ThemeSec:CreateDropdown("AI Model Preset Theme", { "One Protocol (Matcha)", "Dark Storm (Thunderstorm)", "Gemini (Google)", "ChatGPT (OpenAI)", "Claude (Anthropic)", "Qwen (Alibaba)" }, "One Protocol (Matcha)", function(aiThemeName)
    applyAITheme(aiThemeName)
  end)
  ThemeSec:CreateDropdown("UI Accent Theme", { "Green (Emerald)", "Purple (Neon)", "Blue (Cyber)", "Red (Ruby)", "Orange (Amber)", "Pink (Cyberpunk)", "Cyan (Ice)", "Gold (Deluxe)", "Dark (Minimal)", "Rainbow (Dynamic)" }, "Green (Emerald)", function(themeName)
    applyUITheme(themeName)
  end)
  ThemeSec:CreateDropdown("UI Background Style", { "Dark (Default)", "Midnight Void", "Deep Obsidian", "Slate Steel" }, "Dark (Default)", function(bgThemeName)
    applyUIBgTheme(bgThemeName)
  end)
  ThemeSec:CreateButton("Reset Theme to Default", function()
    applyAITheme("One Protocol (Matcha)")
    applyUITheme("Green (Emerald)")
    applyUIBgTheme("Dark (Default)")
  end)
  local DataSec = SettingsTab:CreateSection("Session & Stats Management")
  DataSec:CreateButton("Reset Session Stats", function()
    FarmStats.SessionCoins = 0
    FarmStats.SessionStartTime = os.clock()
  end)
  local SystemSec = SettingsTab:CreateSection("Engine & Diagnostics")
  SystemSec:CreateLabel("One Protocol 8.8.26_2beta", Colors.Accent)
  SystemSec:CreateLabel("- Engine: Matcha External LuaVM")
  SystemSec:CreateLabel("- Architecture: Monolithic Single-Script")
  SystemSec:CreateLabel("- GUI: 1:1 Pixel-Perfect Drawing")
  SystemSec:CreateLabel("- Status: All Systems Operational")
end

function UI_BUILDERS.buildConfigTab()
  local Window = LibraryData.Window
  local ConfigTab = Window:CreateTab("Config")
  local ConfigSec = ConfigTab:CreateSection("Profile Configuration Manager")
  local selectedConfigName = "default"
  local configList = GetSavedConfigList()
  ConfigSec:CreateInput("Config Name...", "default", function(val)
    if val and #val > 0 then
      selectedConfigName = val
    end
  end)
  local configDropdown = ConfigSec:CreateDropdown("Select Profile", configList, configList[1] or "default", function(selected)
    selectedConfigName = selected
  end)
  ConfigSec:CreateLabel("- Config Actions -", Colors.Accent)
  ConfigSec:CreateButton("- Save Config Profile", function()
    if selectedConfigName and #selectedConfigName > 0 then
      local ok = SaveConfigProfile(selectedConfigName)
      if ok then
        configList = GetSavedConfigList()
        configDropdown:UpdateOptions(configList, selectedConfigName)
      end
    end
  end)
  ConfigSec:CreateButton("- Load / Run Config", function()
    if selectedConfigName and #selectedConfigName > 0 then
      local ok = LoadConfigProfile(selectedConfigName)
    end
  end)
  ConfigSec:CreateButton("- Refresh List", function()
    configList = GetSavedConfigList()
    configDropdown:UpdateOptions(configList, selectedConfigName)
  end)
  ConfigSec:CreateButton("- Delete Selected Config", function()
    if selectedConfigName and #selectedConfigName > 0 then
      DeleteConfigProfile(selectedConfigName)
      configList = GetSavedConfigList()
      selectedConfigName = configList[1] or "default"
      configDropdown:UpdateOptions(configList, selectedConfigName)
    end
  end)
end

UI_BUILDERS.buildInfoTab();
UI_BUILDERS.buildAutoFarmTab();
UI_BUILDERS.buildMovementTab();
UI_BUILDERS.buildESPTab();
UI_BUILDERS.buildTeleportsTab();
UI_BUILDERS.buildSettingsTab();
UI_BUILDERS.buildConfigTab();
print("One Protocol 8.8.26_2beta - Matcha Edition Loaded cleanly!")
