--[[
[+] Adopt Me AutoFarm GUI V1.2
[+] [FIXED] Truck and Compass Coins autofarm
[+] [UPDATED] Truck tokens now use a physical drop to ensure collection.
[+] [UPDATED] Bucket Autofarm (after giving the bucket, it should pick up the coins)
[+] [PATCHED] Vector3Meta crashes fixed with pcalls and load-delays.
[+] [ADDED] Anti-AFK System with customizable jump interval.
]]

textprint = "--- ADOPT ME AUTO-FARM V1.2 (Anti-AFK Edition)" 
local config = {
    Beam_AutoFarm = false,
    Beam_Cooldown = 0.05,
    
    Token_AutoFarm = true,
    Token_Cooldown = 0.05,
    
    Truck_AutoFarm = true,
    Bucket_AutoFarm = true,
    
    Anti_AFK = false,
    Anti_AFK_Time = 30, -- Tiempo por defecto en segundos
    
    LOGS = false,
    CoinLogs = false 
}
-- Función auxiliar para Logs
local function EventLog(msg)
    if config.LOGS then
        print("--- [LOG] " .. msg)
    end
end

UI.AddTab("AutoFarm", function(tab)
    local sec = tab:Section("Configuration", "Left")
    sec:Toggle("truck_toggle", "Truck Idle & Token Farm", config.Truck_AutoFarm, function(state)
        config.Truck_AutoFarm = state
    end)
    sec:Toggle("token_toggle", "Token/Coins AutoFarm", config.Token_AutoFarm, function(state)
        config.Token_AutoFarm = state
    end)
    sec:SliderInt("token_cooldown", "Token TP Cooldown (ms)", 1, 100, 5, function(val)
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
    
    -- [ NUEVA SECCIÓN: ANTI-AFK ]
    local secAFK = tab:Section("Anti-AFK System", "Left")
    secAFK:Toggle("anti_afk_toggle", "Enable Anti-AFK (Jump)", config.Anti_AFK, function(state)
        config.Anti_AFK = state
    end)
    secAFK:SliderInt("anti_afk_time", "Jump Interval (s)", 1, 300, 30, function(val)
        config.Anti_AFK_Time = val
    end)

    local secTP = tab:Section("Instant Actions & TPs", "Right")
    secTP:Button("TP to Bucket", function()
        local character = game.Players.LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bucket = workspace:FindFirstChild("Bucket")
            local rootPart = bucket and bucket:FindFirstChild("Root")
            if rootPart and rootPart:IsA("BasePart") then
                local success, pos = pcall(function() return rootPart.Position end)
                if success and typeof(pos) == "Vector3" then
                    hrp.Velocity = Vector3.new(0, 0, 0)
                    hrp.Position = pos + Vector3.new(0, 1.5, 0)
                    print("--- [Manual TP] Teleported to Bucket successfully!")
                end
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
                local success, pos = pcall(function() return poly.Position end)
                if success and typeof(pos) == "Vector3" then
                    hrp.Position = pos + Vector3.new(0, 9, 0)
                    print("--- [Manual TP] Teleported on top of Truck Mesh (+9)!")
                end
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

-- [ ANTI-AFK LOOP ]
task.spawn(function()
    local elapsed = 0
    while true do
        task.wait(1)
        if config.Anti_AFK then
            elapsed = elapsed + 1
            if elapsed >= config.Anti_AFK_Time then
                if keypress and keyrelease then
                    keypress(0x20) -- Espacio (Saltar)
                    task.wait(0.1)
                    keyrelease(0x20)
                    if config.LOGS then print("--- [Anti-AFK] Saltando para evitar desconexión.") end
                end
                elapsed = 0
            end
        else
            -- Si se desactiva el toggle, el contador se resetea a 0 para no saltar inmediatamente al volver a encenderlo
            elapsed = 0
        end
    end
end)

-- [ MAIN AUTOFARM LOOP ]
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
            
            -- [1] BUCKET SEQUENCE
            if config.Bucket_AutoFarm and bucketRoot and bucketRoot:IsA("BasePart") then
                task.wait(0.3)
                local successBucket, bucketPos = pcall(function() return bucketRoot.Position end)
                
                if successBucket and typeof(bucketPos) == "Vector3" then
                    if config.CoinLogs then
                        print("--- [Priority] Bucket detected! Starting precise bucket-coin sequence.")
                    end
                    
                    hrp.Velocity = Vector3.new(0, 0, 0)
                    hrp.Position = bucketPos + Vector3.new(0, 1.5, 0)
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
                    
                    if config.CoinLogs then print("--- [Sequence] Bucket delivered. Waiting 0.3 seconds for coins...") end
                    task.wait(0.3)
                    
                    if config.Token_AutoFarm then
                        if config.CoinLogs then print("--- [Sequence] Cleaning spawned coins from the map...") end
                        local children = workspace:GetChildren()
                        local immediateTokens = {}
                        
                        for i = 1, #children do
                            local child = children[i]
                            if child.Name == "TokenPickup" then
                                local col = child:FindFirstChild("Collider") or child
                                if col:IsA("BasePart") then table.insert(immediateTokens, col) end
                            end
                        end
                        
                        if #immediateTokens > 0 then
                            task.wait(0.2)
                            for _, token in ipairs(immediateTokens) do
                                if token and token.Parent and token:IsA("BasePart") and hrp then
                                    local successPos, tPos = pcall(function() return token.Position end)
                                    if successPos and typeof(tPos) == "Vector3" then
                                        hrp.Velocity = Vector3.new(0, 0, 0)
                                        hrp.Position = tPos + Vector3.new(0, 1.5, 0)
                                        task.wait(config.Token_Cooldown)
                                    end
                                end
                            end
                        end
                    end
                end
                continue 
            end
            -- [ MAIN LOOP CON LOGS ]
            task.spawn(function()
                while true do
                    -- ... (lógica de detección)
                    
                    local truck = GetTruckMeshInstance()
                    if truck then 
                         -- Si detectas movimiento:
                         -- 
                    end
                    
                    local bucket = workspace:FindFirstChild("Bucket")
                    if bucket then
                         -- EventLog("Buckets have spawned")
                    end
                    
                    task.wait(0.5)
                end
            end)
            -- [2] TRUCK & BISON LOGIC
            local bisonActive = workspace:FindFirstChild("Bison")
            local truckPart = GetTruckMeshInstance()

            if config.Truck_AutoFarm and truckPart then
                if not bisonActive then
                    local tokens = {}
                    local children = workspace:GetChildren()
                    
                    for i = 1, #children do
                        local child = children[i]
                        if child.Name == "TokenPickup" then
                            local col = child:FindFirstChild("Collider") or child
                            if col:IsA("BasePart") then table.insert(tokens, col) end
                        end
                    end
                    
                    if #tokens > 0 then
                        for _, token in ipairs(tokens) do
                            if config.Bucket_AutoFarm and workspace:FindFirstChild("Bucket") then break end
                            if not token or not token.Parent or not token:IsA("BasePart") then
                                continue
                            end
                            
                            local successPos, targetPos = pcall(function() return token.Position end)
                            if successPos and typeof(targetPos) == "Vector3" and hrp then
                                hrp.Velocity = Vector3.new(0, -10, 0) 
                                hrp.Position = targetPos + Vector3.new(0, 2.5, 0)
                                task.wait(config.Token_Cooldown)
                            end
                        end
                    else
                        local successTruck, trkPos = pcall(function() return truckPart.Position end)
                        if successTruck and typeof(trkPos) == "Vector3" and truckPart.Parent and hrp then
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            hrp.Position = trkPos + Vector3.new(0, 9, 0)
                        end
                    end
                    
                    task.wait(0.05)
                    continue
                end
            end

            -- [3] GENERAL LIGHT BEAM & TOKEN FARM
            local currentTargets = {}
            local allChildren = workspace:GetChildren()
            
            for i = 1, #allChildren do
                local child = allChildren[i]
                if config.Beam_AutoFarm and child.Name == "SmallLightBeam" then
                    if child:IsA("BasePart") then
                        table.insert(currentTargets, {Part = child, Type = "Beam"})
                    elseif child:IsA("Model") then
                        local primary = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
                        if primary then table.insert(currentTargets, {Part = primary, Type = "Beam"}) end
                    end
                elseif config.Token_AutoFarm and child.Name == "TokenPickup" then
                    local colliderPart = child:FindFirstChild("Collider")
                    if colliderPart and colliderPart:IsA("BasePart") then
                        table.insert(currentTargets, {Part = colliderPart, Type = "Token"})
                    elseif child:IsA("BasePart") then
                        table.insert(currentTargets, {Part = child, Type = "Token"})
                    end
                end
            end
            
            if #currentTargets > 0 then
                for _, item in ipairs(currentTargets) do
                    if config.Bucket_AutoFarm and workspace:FindFirstChild("Bucket") then break end
                    local target = item.Part
                    local itemType = item.Type

                    if target and target.Parent and hrp and target:IsA("BasePart") then
                        local successPos, targetPos = pcall(function() return target.Position end)
                        
                        if successPos and typeof(targetPos) == "Vector3" then
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            hrp.Position = targetPos + Vector3.new(0, 1.5, 0)
                                                                                                        
                            if itemType == "Token" and config.Token_AutoFarm then
                                task.wait(config.Token_Cooldown)
                            elseif itemType == "Beam" and config.Beam_AutoFarm then
                                task.wait(config.Beam_Cooldown)
                            end
                        end
                    end
                end
            end
        end
        task.wait(ScanCooldown)
    end
end)
