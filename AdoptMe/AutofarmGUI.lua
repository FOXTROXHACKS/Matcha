--[[
[+] ADOPT ME AutoFarm GUI v1.4
[+] OPTIMIZED: Removed internal 1s delays from Token/Beam collections for maximum speed.
[+] CUSTOM ACTION SCRIPT: Bucket Detection Sequential Routine
[+] Hex Key Events Incorporated (E = 0x45)
[+] Fixed Token Filter (game.Workspace.TokenPickup.Collider)
]]
_G.Beam_AutoFarm = true
_G.Token_AutoFarm = true
_G.Bucket_AutoFarm = true
_G.TP_Cooldown = 0.05
_G.LOGS = false

UI.AddTab("AutoFarm", function(tab)
    local sec = tab:Section("Configuration", "Left")
    sec:Toggle("beam_autofarm", "Light Beam AutoFarm", _G.Beam_AutoFarm, function(state)
        _G.Beam_AutoFarm = state
    end)
    sec:Toggle("token_autofarm", "Token/Coins AutoFarm", _G.Token_AutoFarm, function(state)
        _G.Token_AutoFarm = state
    end)
    sec:Toggle("bucket_autofarm", "Bucket AutoFarm", _G.Bucket_AutoFarm, function(state)
        _G.Bucket_AutoFarm = state
    end)
    sec:SliderInt("tp_cooldown_slider", "TP Cooldown (ms)", 1, 100, 5, function(val)
        _G.TP_Cooldown = val / 100
    end)
    sec:Toggle("logs_toggle", "Position Logs", _G.LOGS, function(state)
        _G.LOGS = state
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

local ScanCooldown = 0.3 -- Tiempo de espera si no hay nada en el mapa
local TotalItemsFound = 0

local player = game.Players.LocalPlayer
local recolectando = false

print("--- ADOPT ME AUTO-FARM V1.4 LOADED (MAX SPEED COINS) ---")

task.spawn(function()
    while true do
        if not _G.Beam_AutoFarm and not _G.Token_AutoFarm and not _G.Bucket_AutoFarm then 
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
                if _G.Beam_AutoFarm and child.Name == "SmallLightBeam" then
                    if child:IsA("BasePart") then
                        table.insert(currentTargets, {Part = child, Type = "Beam"})
                    elseif child:IsA("Model") then
                        local primary = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
                        if primary then table.insert(currentTargets, {Part = primary, Type = "Beam"}) end
                    end
                
                -- 2. Monedas / Tokens (game.Workspace.TokenPickup.Collider)
                elseif _G.Token_AutoFarm and child.Name == "TokenPickup" then
                    local colliderPart = child:FindFirstChild("Collider")
                    if colliderPart and colliderPart:IsA("BasePart") then
                        table.insert(currentTargets, {Part = colliderPart, Type = "Token"})
                    elseif child:IsA("BasePart") then
                        table.insert(currentTargets, {Part = child, Type = "Token"})
                    end

                -- 3. Buckets
                elseif _G.Bucket_AutoFarm and child.Name == "Bucket" then
                    local rootPart = child:FindFirstChild("Root")
                    if rootPart and rootPart:IsA("BasePart") then
                        table.insert(currentTargets, {Part = rootPart, Type = "Bucket"})
                    end
                end
            end

            if #currentTargets > 0 then
                recolectando = true
                for _, item in ipairs(currentTargets) do
                    local target = item.Part
                    local itemType = item.Type

                    if target and target.Parent and hrp and target:IsA("BasePart") then
                        
                        -- LÓGICA SECUENCIAL PARA EL BUCKET (Mantiene sus tiempos específicos)
                        if itemType == "Bucket" then
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
                            
                            if _G.LOGS then
                                print("[AdoptMe Sequential] Processed Bucket -> Water -> Truck!")
                            end

                            task.wait(2)
                        
                        -- LÓGICA ULTRA RÁPIDA PARA BEAMS Y TOKENS (Usa el slider de la UI)
                        else
                            local targetPos = target.Position
                            if targetPos then
                                hrp.Velocity = Vector3.new(0, 0, 0)
                                hrp.Position = targetPos + Vector3.new(0, 1.5, 0)
                                
                                if _G.LOGS then
                                    TotalItemsFound = TotalItemsFound + 1
                                    print("[AdoptMe Farm] Collected: " .. tostring(itemType) .. " [Total: " .. TotalItemsFound .. "]")
                                end
                                
                                -- Espera estrictamente lo que marque tu slider de Cooldown (ej: 0.05s)
                                task.wait(_G.TP_Cooldown)
                            end
                        end

                    end
                end
            else                recolectando = false
            end
        end
        
        -- Pausa del bucle principal al terminar una ronda de escaneo
        task.wait(recolectando and _G.TP_Cooldown or ScanCooldown)
    end
end)
