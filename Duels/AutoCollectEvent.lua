local player = game.Players.LocalPlayer

task.spawn(function()
    while true do
        task.wait(0.1)
        
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        
        if hrp then
            local spawnablesFolder = workspace:FindFirstChild("SpawnablesClient")
            
            if not spawnablesFolder then
                task.wait(0.5)
                continue
            end

            for i, v in pairs(spawnablesFolder:GetChildren()) do
                local touchPart = v:FindFirstChild("Touch")
                if touchPart and touchPart:IsA("BasePart") then
                    touchPart.CFrame = hrp.CFrame
                end
            end
        end
    end
end)
