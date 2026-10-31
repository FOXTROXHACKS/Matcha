local player = game:GetService("Players").LocalPlayer

task.spawn(function()
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local folder = workspace:FindFirstChild("HalloweenHouses")
        print("root:", root, "| folder:", folder)

        if root and folder then
            local count = 0
            for _, d in ipairs(folder:GetDescendants()) do                if d.Name == "DoorEffects" then
                    count = count + 1
                    local ok, pos = pcall(function() return d.Position end)
                    if ok and pos then
                        root.Position = pos + Vector3.new(0, 0, 0)
                        task.wait(0.1)
                    else
                        print("Beacon sin Position:", d.ClassName)
                    end
                end
            end
            print("Beacons encontrados:", count)
        end
end)
