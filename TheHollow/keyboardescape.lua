local player = game:GetService("Players").LocalPlayer

task.spawn(function()
    while task.wait(1) do
        local folder = workspace:FindFirstChild("HalloweenHouses")
        if folder then
            for _, d in ipairs(folder:GetDescendants()) do
                if d.Name == "DoorEffects" then
                    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    local ok, pos = pcall(function() return d.Position end)
                    if root and ok and pos then
                        root.Position = pos
                        task.wait(0.2)
                    end
                end
            end
        end
    end
end)
