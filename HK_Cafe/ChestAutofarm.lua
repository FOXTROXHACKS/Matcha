local Chest_Autofarm = true
local WAIT_TIME = 4
local TP_Height = 3


local NO_CHEST_NOTIFY_COOLDOWN = 120
local PRINT_INTERVAL = 60
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local F_KEY = 0x46

setrobloxinput(true)

local visited = {}
local lastNoChestNotify = 0
local lastStatusPrint = 0

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

-- Devuelve: tapa, cofre, cantidad total de cofres en el mapa
local function getNextLid()
    local folder = workspace:FindFirstChild("TreasureEntity")
    if not folder then return nil, nil, 0 end

    local count = 0
    local nextLid, nextChest

    for _, chest in ipairs(folder:GetChildren()) do
        local lid = chest:FindFirstChild("TreasureLid")
        if lid then
            count = count + 1
            if not nextLid and not visited[chest.Address] then
                nextLid, nextChest = lid, chest
            end
        end
    end

    if nextLid then
        return nextLid, nextChest, count
    end

    if count > 0 then
        visited = {}
    end
    return nil, nil, count
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if not Chest_Autofarm then continue end

        local root = getRoot()
        if not root or not isrbxactive() then continue end

        local lid, chest, count = getNextLid()

        -- Print de estado cada 60s
        if (tick() - lastStatusPrint) >= PRINT_INTERVAL then
            lastStatusPrint = tick()
            if count > 0 then
                print("[LOG] Chests found: " .. count)
            else
                print("[LOG] No chests found")
            end
        end

        if not lid then
            -- Aviso de "no hay cofres" con cooldown de 2 minutos
            if count == 0 then
                visited = {} -- limpia direcciones viejas
                if (tick() - lastNoChestNotify) >= NO_CHEST_NOTIFY_COOLDOWN then
                    lastNoChestNotify = tick()
                    notify("There's no more chests at this moment", "Auto Cofres", 4)
                end
            end
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
