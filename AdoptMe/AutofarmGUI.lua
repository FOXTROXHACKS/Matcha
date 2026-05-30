--[[
[+] ADOPT ME AutoFarm GUI v1.8
[+] OPTIMIZED: Removed all global variables (_G) and replaced with a local config table.
[+] FIXED GUI: Stable unique keys for Matcha engine stability.
[+] INDEPENDENT SLIDERS: Separate Cooldowns for Beams and Tokens
[+] Custom Action Script: Bucket Sequential Routine (E = 0x45)
]]

-- Tabla de configuración local (reemplaza por completo a _G)
local config = {
    Beam_AutoFarm = true,
    Beam_Cooldown = 0.05,
    
    Token_AutoFarm = true,
    Token_Cooldown = 0.02,
    
    Bucket_AutoFarm = true,
    LOGS = false
}

UI.AddTab("AutoFarm", function(tab)
    local sec = tab:Section("Configuration", "Left")
    
    -- GRUPO BEAMS
    sec:Toggle("beam_toggle", "Light Beam AutoFarm", config.Beam_AutoFarm, function(state)
        config.Beam_AutoFarm = state
    end)
    sec:SliderInt("beam_cooldown", "Beam TP Cooldown (ms)", 1, 100, 5, function(val)
        config.Beam_Cooldown = val / 100
    end)
    
    -- GRUPO TOKENS / COINS
    sec:Toggle("token_toggle", "Token/Coins AutoFarm", config.Token_AutoFarm, function(state)
        config.Token_AutoFarm = state
    end)
    sec:SliderInt("token_cooldown", "Token TP Cooldown (ms)", 1, 100, 2, function(val)
        config.Token_Cooldown = val / 100
    end)
    
    -- RESTO DE CONFIGURACIÓN
    sec:Toggle("bucket_toggle", "Bucket AutoFarm", config.Bucket_AutoFarm, function(state)
        config.Bucket_AutoFarm = state
    end)
    sec:Toggle("logs_toggle", "Position Logs", config.LOGS, function(state)
        config.LOGS = state
    end)

    -- SECCIÓN DE ACCIONES Y TELETRANSPORTES
    local secTP = tab:Section("Instant Actions & TPs", "Right")
    
    secTP:Button("Simulate Press E", function()
        if keypress and keyrelease then
            keypress(0x45)
            task.wait(0.5)
            keyrelease(0x45)
            print("--- [KeyPress] Key 'E' (0x45) simulated successfully!")
        else
            print("--- [ERROR] 'keypress' environment function missing.")
        end
    end)
    
    secTP:Button("TP to Bucket", function()
        local character = game.Players.LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bucket = workspace:FindFirstChild("Bucket")
            local rootPart = bucket and bucket:FindFirstChild("Root")
            if rootPart and rootPart:IsA("BasePart") then
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.Position = rootPart.Position + Vector3.new(0, 1.5, 0)
                print("--- [AdoptMe] Teleported to Bucket successfully!")
            else
                print("--- [AdoptMe] Bucket not found in workspace.")
            end
        end
    end)

    secTP:Button("TP to Event Stand", function()
        local character = game.Players.LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.Position = Vector3.new(-339.17, 31.02 + 1.5, -1448.33)
            print("--- [AdoptMe] Teleported to Event Stand Fixed Position!")
        end
    end)
end)

local ScanCooldown = 0.3 
local TotalItemsFound = 0
local player = game.Players.LocalPlayer

print("--- ADOPT ME AUTO-FARM V1.8 LOADED (LOCAL STORAGE) ---")

task.spawn(function()
    while true do
        if not config.Beam_AutoFarm and not config.Token_AutoFarm and not config.Bucket_AutoFarm then 
            task.wait(0.5) 
            continue 
        end

        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        if hrp then
            local currentTargets = {}
            local allChildren = workspace:GetChildren()
            
            for i = 1, #allChildren do
                local child = allChildren[i]
                
                -- 1. Light Beams
                if config.Beam_AutoFarm and child.Name == "SmallLightBeam" then
                    if child:IsA("BasePart") then
                        table.insert(currentTargets, {Part = child, Type = "Beam"})
                    elseif child:IsA("Model") then
                        local primary = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
                        if primary then table.insert(currentTargets, {Part = primary, Type = "Beam"}) end
                    end
                
                -- 2. Monedas / Tokens
                elseif config.Token_AutoFarm and child.Name == "TokenPickup" then
                    local colliderPart = child:FindFirstChild("Collider")
                    if colliderPart and colliderPart:IsA("BasePart") then
                        table.insert(currentTargets, {Part = colliderPart, Type = "Token"})
                    elseif child:IsA("BasePart") then
                        table.insert(currentTargets, {Part = child, Type = "Token"})
                    end

                -- 3. Buckets
                elseif config.Bucket_AutoFarm and child.Name == "Bucket" then
                    local rootPart = child:FindFirstChild("Root")
                    if rootPart and rootPart:IsA("BasePart") then
                        table.insert(currentTargets, {Part = rootPart, Type = "Bucket"})
                    end
                end
            end

            if #currentTargets > 0 then
                for _, item in ipairs(currentTargets) do
                    local target = item.Part
                    local itemType = item.Type

                    if target and target.Parent and hrp and target:IsA("BasePart") then
                        
                        -- SECUENCIA COMPLETA DEL BUCKET
                        if itemType == "Bucket" and config.Bucket_AutoFarm then
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            hrp.Position = target.Position + Vector3.new(0, 1.5, 0)
                            task.wait(0.2)

                            hrp.Velocity = Vector3.new(0, 0, 0)
                            hrp.Position = Vector3.new(-340.42, 31.03 + 1.5, -1445.74)
                            task.wait(0.2)

                            if keypress and keyrelease then
                                keypress(0x45)
                                task.wait(0.5)
                                keyrelease(0x45)
                            end
                            task.wait(0.2)

                            hrp.Velocity = Vector3.new(0, 0, 0)
                            hrp.Position = Vector3.new(-322.07, 31.03 + 1.5, -1447.33)
                            
                            if config.LOGS then
                                print("[AdoptMe Sequential] Processed Bucket -> Water -> Truck!")
                            end

                            task.wait(2)
                        
                        -- RECOLECCIÓN RÁPIDA CON COOLDOWNS LOCALES
                        elseif itemType == "Token" and config.Token_AutoFarm then
                            local targetPos = target.Position
                            if targetPos then
                                hrp.Velocity = Vector3.new(0, 0, 0)
                                hrp.Position = targetPos + Vector3.new(0, 1.5, 0)
                                
                                if config.LOGS then
                                    TotalItemsFound = TotalItemsFound + 1
                                    print("[AdoptMe Farm] Collected: Token [Total: " .. TotalItemsFound .. "]")
                                end
                                task.wait(config.Token_Cooldown)
                            end

                        elseif itemType == "Beam" and config.Beam_AutoFarm then
                            local targetPos = target.Position
                            if targetPos then
                                hrp.Velocity = Vector3.new(0, 0, 0)
                                hrp.Position = targetPos + Vector3.new(0, 1.5, 0)
                                
                                if config.LOGS then
                                    TotalItemsFound = TotalItemsFound + 1
                                    print("[AdoptMe Farm] Collected: Beam [Total: " .. TotalItemsFound .. "]")
                                end
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
