local AutoFarmWins = false
local player = game:GetService("Players").LocalPlayer

UI.AddTab("Farm", function(tab)
    local sec = tab:Section("Wins Autofarm", "Left")
    
    sec:Toggle("win_toggle", "Enable WinButton Farm", AutoFarmWins, function(state)
        AutoFarmWins = state
        if state then
            notify("Autofarm", "Enabled", 2)
        else
            notify("Autofarm", "Disabled", 2)
        end
    end)
end)

task.spawn(function()
    while true do
        if AutoFarmWins then
            local character = player.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")

            local winFolder = game.Workspace:FindFirstChild("Map") and 
                              game.Workspace.Map:FindFirstChild("World1") and 
                              game.Workspace.Map.World1:FindFirstChild("WinButtons")

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
					          notify("Autofarm", "Finished", 2)
                    task.wait(5)
                end
            end
        end
        task.wait(0.5)
    end
end)
