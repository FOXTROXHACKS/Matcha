_G.Duels_Autofarm = true
_G.Cooldown_Duels = 0.3
task.wait(0.1)
local player = game:GetService("Players").LocalPlayer
local spawnablesFolder = workspace.Spawnables.SpawnablesClient

UI.AddTab("Duels", function(tab)
    local sec = tab:Section("Duels Settings", "Left")

    sec:Toggle("duels_toggle", "Enable AutoFarm", _G.Duels_Autofarm, function(state)
        _G.Duels_Autofarm = state
        local statusText = state and "On" or "Off"
        notify("Autofarm", "Status: " .. statusText, 2)
    end)

    sec:SliderInt("duels_cooldown", "Collection Delay (ms)", 1, 100, (_G.Cooldown_Duels * 100), function(val)
        _G.Cooldown_Duels = val / 100
    end)
end)
task.spawn(function()
	notify("Autofarm","Loaded Sucessfuly",2)
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
                        local t = 0
                        while t < _G.Cooldown_Duels do
                            if not UI.GetValue("duels_toggle") then break end
                            task.wait(0.05)
                            t = t + 0.05
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)
