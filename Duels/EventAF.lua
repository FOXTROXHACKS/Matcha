_G.Duels_Autofarm = false
_G.Auto_TP_Pad = false
_G.Cooldown_Duels = 0.03

local PadWaitTime = 5
local PadPath = workspace.PadZones.PadZone5.Pad1.Pad
local player = game:GetService("Players").LocalPlayer
local spawnablesFolder = workspace.Spawnables.SpawnablesClient
local lastPadTP = 0

UI.AddTab("Duels", function(tab)
    local sec = tab:Section("Main Settings", "Left")
    sec:Toggle("duels_toggle", "Enable AutoFarm", _G.Duels_Autofarm, function(state)
        _G.Duels_Autofarm = state
        notify("Autofarm", (state and "Enabled" or "Disabled"), 2)
    end)
    sec:Toggle("pad_toggle", "Auto TP Pad (5s)", _G.Auto_TP_Pad, function(state)
        _G.Auto_TP_Pad = state
        notify("Pad TP", (state and "Active" or "Inactive"), 2)
    end)
    sec:SliderInt("duels_cooldown", "Collection Delay (ms)", 1, 100, (_G.Cooldown_Duels * 100), function(val)
        _G.Cooldown_Duels = val / 100
    end)
end)
task.spawn(function()
    while true do
        if not UI.GetValue("duels_toggle") then 
            task.wait(0.5) 
            continue 
        end
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local items = spawnablesFolder:GetChildren()
            if #items > 0 then
                for _, item in ipairs(items) do
                    if not UI.GetValue("duels_toggle") then break end

                    if item:IsA("MeshPart") and item.Parent ~= nil then
                        pcall(function()
                            hrp.CFrame = item.CFrame + Vector3.new(0, 3, 0)
                        end)
                        task.wait(_G.Cooldown_Duels)
                    end
                end
                lastPadTP = 0
            else
                if UI.GetValue("pad_toggle") and PadPath then
                    local currentTime = tick()
                    
                    if (currentTime - lastPadTP) >= PadWaitTime then
                        pcall(function()
                            hrp.CFrame = PadPath.CFrame + Vector3.new(0, 3, 0)
                        end)
                        print("[MATCHA]: 5s Check - Returning to Pad")
                        lastPadTP = currentTime
                    end
                end
                task.wait(1)
            end
        end
        task.wait(0.1)
    end
end)
