local AutoFarmWins = false
local player = game:GetService("Players").LocalPlayer

UI.AddTab("Farm", function(tab)
    local sec = tab:Section("Wins Autofarm", "Left")
    
    sec:Toggle("win_toggle", "Enable WinButton Farm", AutoFarmWins, function(state)
        AutoFarmWins = state
        notify("Autofarm", (state and "Enabled" or "Disabled"), 2)
    end)
end)

-- Función para buscar la carpeta de WinButtons sin importar el mundo
local function getWinButtonsFolder()
    local mapFolder = game.Workspace:FindFirstChild("Map")
    if not mapFolder then return nil end
    
    -- Recorre los hijos de "Map" (World1, World2, etc.)
    for _, world in pairs(mapFolder:GetChildren()) do
        local buttons = world:FindFirstChild("WinButtons")
        if buttons then
            return buttons -- Devuelve la primera que encuentre
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
                    notify("Autofarm", "Finished Cycle", 2)
                    task.wait(5)
                end
            end
        end
        task.wait(0.5)
    end
end)
