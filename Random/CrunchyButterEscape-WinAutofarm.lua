local AutoFarmWins = false
local CycleWaitTime = 10
local player = game:GetService("Players").LocalPlayer

UI.AddTab("Farm", function(tab)
    local sec = tab:Section("Wins Autofarm", "Left")
    
    sec:Toggle("win_toggle", "Enable WinButton Farm", AutoFarmWins, function(state)
        AutoFarmWins = state
        notify("Autofarm", (state and "Enabled" or "Disabled"), 2)
    end)
    sec:SliderInt("cycle_timer", "Cycle Wait (Seconds)", 1, 20, CycleWaitTime, function(val)
        CycleWaitTime = val
    end)
end)

local function getWinButtonsFolder()
    local mapFolder = game.Workspace:FindFirstChild("Map")
    if not mapFolder then return nil end
    
    for _, world in pairs(mapFolder:GetChildren()) do
        local buttons = world:FindFirstChild("WinButtons")
        if buttons then
            return buttons
        end
    end
    return nil
end

task.spawn(function()
    while true do
        if AutoFarmWins then
            local character = player.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            local winFolder = getWinButtonsFolder()

            if hrp and winFolder then
                local buttons = winFolder:GetChildren()
                
                for _, button in pairs(buttons) do
                    if not AutoFarmWins then break end
                    
                    local basePart = button:FindFirstChild("Base")
                    if basePart and basePart:IsA("BasePart") then
                        hrp.CFrame = basePart.CFrame + Vector3.new(0, 3, 0)
                        task.wait(0.7)
                    end
                end
                
                if AutoFarmWins then
                    notify("Autofarm", "Finished Cycle. Waiting " .. CycleWaitTime .. "s", 2)
                    task.wait(CycleWaitTime)
                end
            end
        end
        task.wait(0.5)
    end
end)
