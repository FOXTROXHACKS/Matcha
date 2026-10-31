local Flower_TP = true
local TP_Delay = 8
local TP_Height = 3
local Rescan_Delay = 5

local LocalPlayer = game:GetService("Players").LocalPlayer
local visited = {}

UI.AddTab("The Hollow", function(tab)
    local sec = tab:Section("Hollow Flowers", "Left")
    sec:Text("Settings")
    sec:Toggle("flower_toggle", "Enable Flower TP", Flower_TP, function(state)
        Flower_TP = state
        if state then visited = {} end
        notify("Flower TP", (state and "Enabled" or "Disabled"), 2)
    end)
    sec:SliderInt("flower_delay", "Delay at each flower (ds)", 1, 50, math.floor(TP_Delay * 10), function(val)
        TP_Delay = val / 10
    end)
    sec:SliderInt("flower_height", "Height offset", 0, 10, TP_Height, function(val)
        TP_Height = val
    end)
end)

local function getRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getMains()
    local list = {}
    local map = workspace
    local landmarks = map and map:FindFirstChild("ShadowFungusNodes")
    if not landmarks then return list end
----game.Workspace.ShadowFungusNodes.FungalNode.VFXGoingInwards
    for _, plant in ipairs(landmarks:GetChildren()) do
        if plant.Name == "FungalNode" then
            local main = plant:FindFirstChild("VFXGoingInwards")
            if main then
                table.insert(list, main)
            end
        end
    end

    return list
end

local function getNextMain(root)
    local mains = getMains()
    local best, bestDist = nil, math.huge

    for _, main in ipairs(mains) do
        if not visited[main.Address] then
            local ok, pos = pcall(function() return main.Position end)
            if ok and pos then
                local d = (pos - root.Position).Magnitude
                if d < bestDist then
                    best, bestDist = main, d
                end
            end
        end
    end

    return best, #mains
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if not Flower_TP then continue end

        local root = getRoot()
        if not root then continue end

        local main, total = getNextMain(root)

        if main then
            pcall(function()
                root.Position = main.Position + Vector3.new(0, TP_Height, 0)
            end)
            visited[main.Address] = true
            task.wait(TP_Delay)
        else
            if total > 0 then
                print("[LOG] Found (" .. total .. " flowers). Rescanning...")
            else
                print("[LOG] No flowers found")
            end
            visited = {}
            task.wait(Rescan_Delay)
        end
    end
end)

notify("The Hollow", "99 Nights in the Forest", 3)
