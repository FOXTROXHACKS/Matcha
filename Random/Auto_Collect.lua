local player = game.Players.LocalPlayer
--game.Workspace.DebrisClient.Pickup116840.HitDetect
task.spawn(function()
    while true do
        task.wait(0.1)
        
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        
        if hrp then
            local spawnablesFolder = workspace:FindFirstChild("DebrisClient")
            
            if not spawnablesFolder then
                task.wait(0.5)
                continue
            end

            for i, v in pairs(spawnablesFolder:GetChildren()) do
                local touchPart = v:FindFirstChild("HitDetect")
                if touchPart and touchPart:IsA("Part") then
                    touchPart.CFrame = hrp.CFrame
            task.wait(0.2)
                end
            end
        end
    end
end)
