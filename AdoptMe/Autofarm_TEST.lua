--[[
[+] Adopt Me AutoFarm GUI V1.2
[+] [ADDED] Anti-AFK system (makes you jump every 60 seconds by default)
[+] [ADDED] MISC Section with Anti-AFK and Event Logs.
[+] [ADDED] Event Log system to track Truck movement, Bucket spawns, and Anti-AFK jumps.
]]

local textprint = "--- ADOPT ME AUTO-FARM V1.2 (Misc, Anti-AFK & Fixes)" 
local config = {
    Beam_AutoFarm = false,
    Beam_Cooldown = 0.05,
    
    Token_AutoFarm = true,
    Token_Cooldown = 0.05,
    
    Truck_AutoFarm = true,
    Bucket_AutoFarm = true,
    
    Anti_AFK = false,
    Anti_AFK_Time = 60,
    
    LOGS = false,
    CoinLogs = false 
}

-- Eventlog stuff
local function EventLog(msg, errr)
    if config.LOGS then
        if errr == 1 then
            error("--- [ERR] " .. msg)
        else
            warn("--- [LOG] " .. msg)
        end
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
    
    -- [ NUEVA SECCIÓN MISC ]
    local secMisc = tab:Section("MISC", "Right")
    secMisc:Toggle("logs_toggle", "Enable Event Logs", config.LOGS, function(state)
        config.LOGS = state
    end)
    secMisc:Toggle("coin_logs_toggle", "Detailed Coin Logs", config.CoinLogs, function(state) 
        config.CoinLogs = state
    end)
    secMisc:Toggle("anti_afk_toggle", "Anti-AFK (Jump)", config.Anti_AFK, function(state)
        config.Anti_AFK = state
    end)
    secMisc:SliderInt("anti_afk_time", "Jump Interval (s)", 1, 300, 60, function(val)
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
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.Position = rootPart.Position + Vector3.new(0, 1.5, 0)
                notify("[Manual TP]","Teleported to Bucket successfully!",5)
            else
                notify("[Manual TP]","Bucket not found in workspace.",5)
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
                notify("[Manual TP]","Teleported on top of Truck Mesh",5)
            else
                hrp.Position = Vector3.new(-322.07, 31.03 + 9, -1447.33)
                notify("[Manual TP]","Truck Mesh not found. Using safe fixed backup coordinates",5)
            end
        end
    end)
    secTP:Button("TP to Water Tank", function()
        local character = game.Players.LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.Position = Vector3.new(-340.42, 31.03 + 1.5, -1445.74)
            notify("[Manual TP]","Teleported to Water Tank Position!",5)
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
                    keypress(0x20)
                    task.wait(0.1)
                    keyrelease(0x20)
                    EventLog("- AntiAFK: Jumped")
                end
                elapsed = 0
            end
        else
            elapsed = 0
        end
    end
end)

local truckWasMoving = false
local bucketWasSpawned = false

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
            local bucketRoot = nil
            
            if bucketFound then
                if not bucketWasSpawned then
                    EventLog("Buckets have spawned")
                    bucketWasSpawned = true
                end
                
                bucketRoot = bucketFound:FindFirstChild("Root")
                if not bucketRoot then
                    task.wait(0.5)
                    bucketRoot = bucketFound:FindFirstChild("Root")
                end
            else
                bucketWasSpawned = false
            end

-------------- [1] BUCKET SEQUENCE
            if config.Bucket_AutoFarm and bucketRoot and bucketRoot:IsA("BasePart") then
                if typeof(bucketRoot.Position) == "Vector3" then
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
                    
                    if config.CoinLogs then EventLog("- [Sequence] Bucket delivered. Waiting 0.3 seconds for coins...") end
                    task.wait(0.3)
                    
                    if config.Token_AutoFarm then
                        if config.CoinLogs then EventLog("- [Sequence] Cleaning spawned coins from the map...") end
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
                                    local tokenPos = token.Position
                                    if typeof(tokenPos) == "Vector3" then
                                        hrp.Velocity = Vector3.new(0, 0, 0)
                                        hrp.Position = tokenPos + Vector3.new(0, 1.5, 0)
                                        task.wait(config.Token_Cooldown)
                                    end
                                end
                            end
                        end
                    end
                end
                continue 
            end
            
-------------- [2] TRUCK & BISON LOGIC
            local bisonActive = workspace:FindFirstChild("Bison")
            local truckPart = GetTruckMeshInstance()

            if config.Truck_AutoFarm and truckPart then
                if not bisonActive then
                    if not truckWasMoving then
                        EventLog(" - Event Started: Truck is moving, farming event")
                        truckWasMoving = true
                    end
                    
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
                            -- Validación estricta para evitar crasheos de Vector3
                            if successPos and typeof(targetPos) == "Vector3" and hrp then
                                hrp.Velocity = Vector3.new(0, -10, 0) 
                                hrp.Position = targetPos + Vector3.new(0, 2.5, 0)
                                
                                task.wait(config.Token_Cooldown)
                            end
                        end
                    else
                        if truckPart.Parent and hrp and typeof(truckPart.Position) == "Vector3" then
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            hrp.Position = truckPart.Position + Vector3.new(0, 9, 0)
                        end
                    end
                    
                    task.wait(0.05)
                    continue
                else
                    truckWasMoving = false
                end
            else
                truckWasMoving = false
            end

-------------- [3] GENERAL LIGHT BEAM & TOKEN FARM
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
                        local targetPos = target.Position
                        if typeof(targetPos) == "Vector3" then
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
