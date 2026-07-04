local Duels_Autofarm = true
local Cooldown_Duels = 0.05
local player = game:GetService("Players").LocalPlayer

local spawnablesFolder = nil 

UI.AddTab("Duels", function(tab)
    local sec = tab:Section("Duels Autofarm - V1.3", "Left")
    sec:Text("Settings")
    
    sec:Toggle("duels_toggle", "Enable AutoFarm", Duels_Autofarm, function(state)
        Duels_Autofarm = state
        notify("Autofarm", (state and "Enabled" or "Disabled"), 2)
    end)
    
    sec:SliderInt("duels_cooldown", "Collection Delay (Seconds)", 1, 60, (Cooldown_Duels * 10), function(val)
        Cooldown_Duels = val / 10
    end)
end)

print("[LOG] Script Loaded")

task.spawn(function()
    while true do
        task.wait(0.1)
        if not Duels_Autofarm then continue end
        
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        spawnablesFolder = workspace:FindFirstChild("SpawnablesClient")
        if not spawnablesFolder then
            task.wait(0.5)
            continue
        end

        local foundItems = {}
        for _, folder in ipairs(spawnablesFolder:GetChildren()) do
            local touchpart = folder:FindFirstChild("Touch")
            if touchpart and touchpart:IsA("BasePart") then
                table.insert(foundItems, touchpart)
            end
        end

        if #foundItems > 0 then
            for _, item in ipairs(foundItems) do
                if not Duels_Autofarm then break end
                if item.Parent then
                    pcall(function() item.CFrame = hrp.CFrame end)
                    task.wait(Cooldown_Duels)
                end
            end
        end
    end
end)
