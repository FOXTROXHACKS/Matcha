local Pumpkin_TP = true
local TP_Delay = 1
local TP_Height = 3
local Rescan_Delay = 5
local E_KEY = 0x45

local LocalPlayer = game:GetService("Players").LocalPlayer
local visited = {}

UI.AddTab("The Hollow", function(tab)
    local sec = tab:Section("Pumpkins", "Left")
    sec:Text("Settings")
    sec:Toggle("school_toggle", "Enable Pumpkin TP", Pumpkin_TP, function(state)
        Pumpkin_TP = state
        if state then visited = {} end
        notify("Pumpkin TP", (state and "Enabled" or "Disabled"), 2)
    end)
    sec:SliderInt("school_delay", "Delay at each pumpkin (ds)", 1, 50, math.floor(TP_Delay * 10), function(val)
        TP_Delay = val / 10
    end)
    sec:SliderInt("school_height", "Height offset", 0, 10, TP_Height, function(val)
        TP_Height = val
    end)
end)

local function getRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getPos(obj)
    local ok, pos = pcall(function() return obj.Position end)
    if ok and pos then return pos end
    return nil
end

local function getLightPart(item)
    local light = item:FindFirstChild("pumpkin_light")
    if not light then return nil end

    if getPos(light) then return light end

    for _, d in ipairs(light:GetDescendants()) do
        if getPos(d) then return d end
    end
    return nil
end

local function getNextPumpkin(root)
    local school = workspace:FindFirstChild("School")
    local folder = school and school:FindFirstChild("ChristmasItem")
    if not folder then return nil, 0 end

    local total = 0
    local best, bestDist, bestId = nil, math.huge, nil

    for _, item in ipairs(folder:GetChildren()) do
        local part = getLightPart(item)
        if part then
            total = total + 1
            if not visited[item.Address] then
                local d = (part.Position - root.Position).Magnitude
                if d < bestDist then
                    best, bestDist, bestId = part, d, item.Address
                end
            end
        end
    end

    return best, total, bestId
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if not Pumpkin_TP then continue end

        local root = getRoot()
        if not root or not isrbxactive() then continue end

        local part, total, id = getNextPumpkin(root)

        if part then
            pcall(function()
                root.Position = part.Position + Vector3.new(0, TP_Height, 0)
            end)
            task.wait(0.2)
            keypress(E_KEY)
            task.wait(0.1)
            keyrelease(E_KEY)

            visited[id] = true
            task.wait(TP_Delay)
        else
            if total > 0 then
                --print("[LOG] Vuelta completa (" .. total .. " calabazas). Reiniciando...")
            else
                --print("[LOG] No se encontraron calabazas")
            end
            visited = {}
            task.wait(Rescan_Delay)
        end
    end
end)

notify("The Hollow Loaded", "Aooni Event", 3)
