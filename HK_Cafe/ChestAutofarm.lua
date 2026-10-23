local Chest_Autofarm = true
local WAIT_TIME = 4
local TP_Height = 3

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local F_KEY = 0x46

setrobloxinput(true)

local visited = {}

UI.AddTab("Cofres", function(tab)
    local sec = tab:Section("Hello Kitty Cafe - Auto Cofres", "Left")
    sec:Text("Settings")
    sec:Toggle("chest_toggle", "Enable AutoFarm", Chest_Autofarm, function(state)
        Chest_Autofarm = state
        if state then visited = {} end
        notify("Auto Cofres", (state and "Enabled" or "Disabled"), 2)
    end)
    sec:SliderInt("chest_wait", "Wait after interacting (s)", 1, 10, WAIT_TIME, function(val)
        WAIT_TIME = val
    end)
    sec:SliderInt("chest_height", "Height TP", 1, 10, TP_Height, function(val)
        TP_Height = val
    end)
end)

local function getRoot()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function getNextLid()
    local folder = workspace:FindFirstChild("TreasureEntity")
    if not folder then return nil end

    local found = false
    for _, chest in ipairs(folder:GetChildren()) do
        local lid = chest:FindFirstChild("TreasureLid")
        if lid then
            found = true
            if not visited[chest.Address] then
                return lid, chest
            end
        end
    end
    if found then
        visited = {}
    end
    return nil
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if not Chest_Autofarm then continue end

        local root = getRoot()
        if not root or not isrbxactive() then continue end

        local lid, chest = getNextLid()
        if not lid then
            task.wait(0.4)
            continue
        end

        pcall(function()
            root.Position = lid.Position + Vector3.new(0, TP_Height, 0)
        end)
        task.wait(0.5)

        keypress(F_KEY)
        task.wait(0.1)
        keyrelease(F_KEY)

        visited[chest.Address] = true
        task.wait(WAIT_TIME)
    end
end)

notify("Auto Chests Loaded", "Hello Kitty Cafe", 3)
