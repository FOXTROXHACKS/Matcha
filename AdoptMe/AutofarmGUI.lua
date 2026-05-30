--[[
[+] ADOPT ME AutoFarm GUI v1.2
[+] FIXED: Event Stand Button now forces your precise absolute coordinates
[+] Added 'Simulate Press E' Button via keypress(69)
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
    
    -- SIMULAR KEYPRESS DE LA TECLA 'E'
    secTP:Button("Simulate Press E", function()
        if keypress and keyrelease then
            keypress(0x45)
            task.wait(0.05)
            keyrelease(0x45)
            print("--- [KeyPress] Key 'E' simulated successfully!")
        elseif keypress then
            keypress(0x45)
            print("--- [KeyPress] Key 'E' pressed.")
        else
            print("--- [ERROR] 'keypress' function not supported by executor.")
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
                print("--- [AdoptMe] Bucket or Root part not found in workspace.")
            end
        end
    end)

    -- CORREGIDO: Fuerza ir a tu nueva posición fija de manera absoluta
    secTP:Button("TP to Event Stand", function()
        local character = game.Players.LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(0, 0, 0)
            
            -- Teletransporte directo a tus nuevas coordenadas exactas (con el +1.5 en Y)
            hrp.Position = Vector3.new(-339.17, 31.02 + 1.5, -1448.33)
            print("--- [AdoptMe] Teleported directly to Event Stand Fixed Position!")
        end
    end)
end)

local Collect = 0.3 
local ScanCooldown = 0.5
local TotalItemsFound = 0

local player = game.Players.LocalPlayer
local recolectando = false

print("--- ADOPT ME AUTO-FARM LOADED (EVENT POSITION FORCED) ---")

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
                        table.insert(currentTargets, child)
                    elseif child:IsA("Model") then
                        local primary = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
                        if primary then table.insert(currentTargets, primary) end
                    end
                
                -- 2. Monedas / Tokens (game.Workspace.TokenPickup.Collider)
                elseif _G.Token_AutoFarm and child.Name == "TokenPickup" then
                    local colliderPart = child:FindFirstChild("Collider")
                    if colliderPart and colliderPart:IsA("BasePart") then
                        table.insert(currentTargets, colliderPart)
                    elseif child:IsA("BasePart") then
                        table.insert(currentTargets, child)
                    end

                -- 3. Buckets
                elseif _G.Bucket_AutoFarm and child.Name == "Bucket" then
                    local rootPart = child:FindFirstChild("Root")
                    if rootPart and rootPart:IsA("BasePart") then
                        table.insert(currentTargets, rootPart)
                    end
                end
            end

            if #currentTargets > 0 then
                recolectando = true
                for _, target in ipairs(currentTargets) do
                    local startTime = tick()
                    while tick() - startTime < Collect do
                        if target and target.Parent and hrp and target:IsA("BasePart") then
                            local targetPos = target.Position
                            if targetPos then
                                hrp.Velocity = Vector3.new(0, 0, 0)
                                hrp.Position = targetPos + Vector3.new(0, 1.5, 0)
                                
                                if _G.LOGS then
                                    TotalItemsFound = TotalItemsFound + 1
                                    local nameDisplayed = target.Name
                                    if target.Name == "Collider" then nameDisplayed = "Token" end
                                    if target.Name == "Root" then nameDisplayed = "Bucket" end
                                    
                                    print("[AdoptMe Farm] Collected: " .. tostring(nameDisplayed) .. " [Total: " .. TotalItemsFound .. "]")
                                end
                            else
                                break
                            end
                            task.wait(1)
                        else
                            break
                        end
                        task.wait()
                    end
                end
            else
                recolectando = false
            end
        end
        
        local waitTime = ScanCooldown
        if recolectando and _G.TP_Cooldown then 
            waitTime = _G.TP_Cooldown 
        end
        task.wait(waitTime)
    end
end)
