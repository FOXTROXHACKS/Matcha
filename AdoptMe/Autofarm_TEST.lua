--[[
[+] Adopt Me AutoFarm GUI v1.1.2
[+] [REMOVED] TriggerWASD completely to optimize performance.
[+] [FIXED] Tokens left behind by replacing WASD with a 3.5-stud vertical drop collision.
[+] [UPDATED] Aggressive sweeping loop that doesn't stop until workspace is completely clear.
]]
textprint = "--- ADOPT ME AUTO-FARM V1.1.2 (Aggressive Drop Sweeper)" 
local config = {
    Beam_AutoFarm = false,
    Beam_Cooldown = 0.05,
    
    Token_AutoFarm = true,
    Token_Cooldown = 0.02,
    
    Truck_AutoFarm = true,
    Bucket_AutoFarm = true,
    LOGS = false,
    CoinLogs = false 
}

UI.AddTab("AutoFarm", function(tab)
    local sec = tab:Section("Configuration", "Left")
    sec:Toggle("truck_toggle", "Truck Idle & Token Farm", config.Truck_AutoFarm, function(state)
        config.Truck_AutoFarm = state
    end)
    sec:Toggle("token_toggle", "Token/Coins AutoFarm", config.Token_AutoFarm, function(state)
        config.Token_AutoFarm = state
    end)
    sec:SliderInt("token_cooldown", "Token TP Cooldown (ms)", 1, 100, 2, function(val)
        config.Token_Cooldown = val / 100
    end)
    sec:Toggle("beam_toggle", "Light Beam AutoFarm", config.Beam_AutoFarm, function(state)
        config.Beam_AutoFarm = state
    end)
    sec:SliderInt("beam_cooldown", "Beam TP Cooldown (ms)", 1, 100, 5, function(val)
        config.Beam_Cooldown = val / 100
    end)
    sec:Toggle("bucket_toggle", "Bucket AutoFarm", config.Bucket_AutoFarm, function(state)
        config.Bucket_AutoFarm = state
    end)
    sec:Toggle("coin_logs_toggle", "Coin Logs & Errors", config.CoinLogs, function(state) 
        config.CoinLogs = state
    end)
    sec:Toggle("logs_toggle", "Position Logs", config.LOGS, function(state)
        config.LOGS = state
    end)

    local secTP = tab:Section("Instant Actions & TPs", "Right")
    secTP:Button("TP to Bucket", function()
        local character = game.Players.LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bucket = workspace:FindFirstChild("Bucket")
            local rootPart = bucket and bucket:FindFirstChild("Root")
            if rootPart and rootPart:IsA("BasePart") then
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.Position = rootPart.Position + Vector3.new(0, 1.5, 0)
                print("--- [Manual TP] Teleported to Bucket successfully!")
            else
                print("--- [Manual TP] Bucket not found in workspace.")
            end
        end
    end)
    secTP:Button("TP to Truck", function()
        local character = game.Players.LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local interiors = workspace:FindFirstChild("Interiors")
            local mainMap = interiors and interiors:FindFirstChild("MainMap!Default")
            local truck = mainMap and mainMap:FindFirstChild("Truck")
            local geometry = truck and truck:FindFirstChild("Geometry")
            local poly = geometry and geometry:FindFirstChild("polySurface95")
            
            hrp.Velocity = Vector3.new(0, 0, 0)
            if poly and poly:IsA("BasePart") then
                hrp.Position = poly.Position + Vector3.new(0, 9, 0)
                print("--- [Manual TP] Teleported on top of Truck Mesh (+9)!")
            else
                hrp.Position = Vector3.new(-322.07, 31.03 + 9, -1447.33)
                print("--- [Manual TP] Truck Mesh not found. Using safe fixed backup coordinates (+9)!")
            end
        end
    end)
    secTP:Button("TP to Water Tank", function()
        local character = game.Players.LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.Position = Vector3.new(-340.42, 31.03 + 1.5, -1445.74)
            print("--- [Manual TP] Teleported to Water Tank Position!")
        end
    end)
end)

local ScanCooldown = 0.2 
local player = game.Players.LocalPlayer

local function GetTruckMeshInstance()
    local interiors = workspace:FindFirstChild("Interiors")
    if interiors then
        local mainMap = interiors:FindFirstChild("MainMap!Default")
        if mainMap then
            local truck = mainMap:FindFirstChild("Truck")
            if truck then
                local geometry = truck:FindFirstChild("Geometry")
                if geometry then
                    local targetMesh = geometry:FindFirstChild("polySurface95")
                    if targetMesh and targetMesh:IsA("BasePart") then
                        return targetMesh
                    end
                end
            end
        end
    end
    return nil
end

print(textprint)
task.spawn(function()
    while true do
        if not config.Beam_AutoFarm and not config.Token_AutoFarm and not config.Bucket_AutoFarm and not config.Truck_AutoFarm then 
            task.wait(0.5) 
            continue 
        end

        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        if hrp then
            local bucketFound = workspace:FindFirstChild("Bucket")
            local bucketRoot = bucketFound and bucketFound:FindFirstChild("Root")

            if config.Bucket_AutoFarm and bucketRoot and bucketRoot:IsA("BasePart") then
                if config.CoinLogs then
                    print("--- [Priority] Bucket detected! Starting precise bucket-coin sequence.")
                end

                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.Position = bucketRoot.Position + Vector3.new(0, 1.5, 0)
                task.wait(0.8)

                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.Position = Vector3.new(-340.42, 31.03 + 1.5, -1445.74)
                task.wait(0.8)
                
                if keypress and keyrelease then
                    keypress(0x45) -- E
                    task.wait(0.3)
                    keyrelease(0x45)
                end
                task.wait(0.5)

                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.Position = Vector3.new(-322.07, 31.03 + 1.5, -1447.33)
                task.wait(0.5)

                if config.CoinLogs then print("--- [Sequence] Bucket delivered. Sweeping spawned tokens...") end
                
                -- BUCLE AGRESIVO POST-BALDE (No sale hasta limpiar todo)
                if config.Token_AutoFarm then
                    local startTime = os.clock()
                    while workspace:FindFirstChild("TokenPickup") and (os.clock() - startTime < 4) do
                        local children = workspace:GetChildren()
                        for i = 1, #children do
                            local child = children[i]
                            if child.Name == "TokenPickup" then
                                local col = child:FindFirstChild("Collider") or child
                                if col and col.Parent and col:IsA("BasePart") and hrp then
                                    hrp.Velocity = Vector3.new(0, 0, 0)
                                    hrp.Position = col.Position + Vector3.new(0, 3.5, 0) -- Caída física
                                    task.wait(config.Token_Cooldown)
                                end
                            end
                        end
                        task.wait(0.01)
                    end
                end
                continue 
            end

            local bisonActive = workspace:FindFirstChild("Bison")
            local truckPart = GetTruckMeshInstance()

            if config.Truck_AutoFarm and truckPart then
                if not bisonActive then
                    -- BUCLE AGRESIVO EN TRUCK (Limpia tokens con caída de gravedad)
                    if workspace:FindFirstChild("TokenPickup") then
                        while workspace:FindFirstChild("TokenPickup") do
                            if config.Bucket_AutoFarm and workspace:FindFirstChild("Bucket") then break end
                            local children = workspace:GetChildren()
                            local foundToken = false
                            
                            for i = 1, #children do
                                local child = children[i]
                                if child.Name == "TokenPickup" then
                                    local col = child:FindFirstChild("Collider") or child
                                    if col and col.Parent and col:IsA("BasePart") and hrp then
                                        foundToken = true
                                        hrp.Velocity = Vector3.new(0, 0, 0)
                                        hrp.Position = col.Position + Vector3.new(0, 3.5, 0) -- Caída de 3.5 studs en lugar de WASD
                                        task.wait(config.Token_Cooldown)
                                    end
                                end
                            end
                            if not foundToken then break end
                            task.wait(0.01)
                        end
                    else
                        if truckPart.Parent and hrp then
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            hrp.Position = truckPart.Position + Vector3.new(0, 9, 0)
                        end
                    end
                else
                    if truckPart.Parent and hrp then
                        local distToIdle = (hrp.Position - (truckPart.Position + Vector3.new(0, 9, 0))).Magnitude
                        if distToIdle > 2 then
                            -- Opcional
                        end
                    end
                end

                if not bisonActive then
                    task.wait(0.05)
                    continue
                end
            end

            -- [ ESCÁNER GENERAL CON BUCLE DE BARRIDO CONSTANTE ]
            if config.Token_AutoFarm and workspace:FindFirstChild("TokenPickup") then
                while workspace:FindFirstChild("TokenPickup") do
                    if config.Bucket_AutoFarm and workspace:FindFirstChild("Bucket") then break end
                    local allChildren = workspace:GetChildren()
                    local tokenProcessed = false
                    
                    for i = 1, #allChildren do
                        local child = allChildren[i]
                        if child.Name == "TokenPickup" then
                            local col = child:FindFirstChild("Collider") or child
                            if col and col.Parent and col:IsA("BasePart") and hrp then
                                tokenProcessed = true
                                hrp.Velocity = Vector3.new(0, 0, 0)
                                hrp.Position = col.Position + Vector3.new(0, 3.5, 0) -- Caída física
                                task.wait(config.Token_Cooldown)
                            end
                        end
                    end
                    if not tokenProcessed then break end
                    task.wait(0.01)
                end
            end

            -- Procesamiento alternativo para Beams si están activos
            if config.Beam_AutoFarm then
                local allChildren = workspace:GetChildren()
                for i = 1, #allChildren do
                    local child = allChildren[i]
                    if child.Name == "SmallLightBeam" and hrp then
                        local targetPart = child:IsA("BasePart") and child or child:FindFirstChildWhichIsA("BasePart")
                        if targetPart then
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            hrp.Position = targetPart.Position + Vector3.new(0, 1.5, 0)
                            task.wait(config.Beam_Cooldown)
                        end
                    end
                end
            end
        end
        task.wait(ScanCooldown)
    end
end)
