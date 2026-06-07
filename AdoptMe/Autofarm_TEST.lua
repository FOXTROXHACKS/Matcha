--[[
[+] Adopt Me AutoFarm GUI V1.3.3
[+] [FIXED] Minigame Cycle 2: Now waits exactly 5s and collects leftover coins.
[+] [REWORKED] Token & Beam Farm: Items are now teleported TO THE PLAYER (Magnet) instead of moving the player.
[+] [ADDED] Toggle for Event Idle TP to prevent automatic grounding when targets are clear.
]]

local textprint = "--- ADOPT ME AUTO-FARM V1.18 (Matcha Absolute Clicks Edition)" 
local config = {
    Boat_AutoFarm = true,
    Trash_AutoFarm = true,
    Token_AutoFarm = true,
    Token_Cooldown = 0.05,
    
    Beam_AutoFarm = false,
    Beam_Cooldown = 0.05,
    
    Idle_TP = true, -- Toggle para activar/desactivar el TP al punto de descanso del evento
    
    Anti_AFK = true, -- Coma corregida
    Anti_AFK_Time = 60,
    
    LOGS = false, 
    CoinLogs = false 
}

-- Sistema de EventLogs
local function EventLog(msg, errr)
    if config.LOGS then
        if errr == 1 then
            error("--- [ERR] " .. msg)
        else
            warn("--- [LOG] " .. msg)
        end
    end
end

-- Función para asegurar que el click se registre en el juego
local function PerformSafeClick()
    if mousemoveabs and mouse1click then
        mousemoveabs(1423, 951) -- Movimiento inicial
        task.wait(0.1)
        mousemoveabs(1423, 952) -- Pequeño ajuste para simular "Hover"
        task.wait(0.5)
        mouse1click()           -- Primer click
    end
end

--[[
Abrir Inventario: 1284, 1483
Regalos: 1069, 1260
tp regalos: 1193, 1035
]]
local function Tp2Event()
    if mousemoveabs and mouse1click then
        mousemoveabs(1284, 1483) -- Movimiento Abrir Inventario
        task.wait(0.1)
        mousemoveabs(1284, 1482) -- Pequeño ajuste para simular "Hover"
        task.wait(0.5)
        mouse1click()           -- Primer click
        task.wait(0.5)
        mousemoveabs(1069, 1260) -- Movimiento Regalos
        task.wait(0.1)
        mousemoveabs(1069, 1261) -- Pequeño ajuste
        task.wait(0.5)
        mouse1click()
        task.wait(0.5)
        mousemoveabs(1193, 1035) -- Movimiento tp
        task.wait(0.1)
        mousemoveabs(1193, 1036) -- Pequeño ajuste
        task.wait(0.5)
        mouse1click()
        PerformSafeClick()
    end
end

UI.AddTab("Event AF", function(tab)
    local sec = tab:Section("Configuration", "Left")
    sec:Toggle("boat_toggle", "Boat Idle & Token Farm", config.Boat_AutoFarm, function(state)
        config.Boat_AutoFarm = state
        notify("[AutoFarm]", "Boat Idle: " .. tostring(state), 2)
    end)
    sec:Toggle("trash_toggle", "Trash Bags Minigame AutoFarm", config.Trash_AutoFarm, function(state)
        config.Trash_AutoFarm = state
        notify("[AutoFarm]", "Trash Minigame: " .. tostring(state), 2)
    end)
    sec:Toggle("token_toggle", "Token/Coins AutoFarm", config.Token_AutoFarm, function(state)
        config.Token_AutoFarm = state
        notify("[AutoFarm]", "Token AutoFarm: " .. tostring(state), 2)
    end)
    sec:Toggle("idle_tp_toggle", "TP to Event Idle Point", config.Idle_TP, function(state)
        config.Idle_TP = state
        notify("[AutoFarm]", "Idle TP: " .. tostring(state), 2)
    end)
    sec:SliderInt("token_cooldown", "Token TP Cooldown (ms)", 1, 100, 5, function(val)
        config.Token_Cooldown = val / 100
    end)
    sec:Toggle("beam_toggle", "Light Beam AutoFarm", config.Beam_AutoFarm, function(state)
        config.Beam_AutoFarm = state
        notify("[AutoFarm]", "Beam AutoFarm: " .. tostring(state), 2)
    end)
    sec:SliderInt("beam_cooldown", "Beam TP Cooldown (ms)", 1, 100, 5, function(val)
        config.Beam_Cooldown = val / 100
    end)
    
    -- [ SECCIÓN MISC ]
    local secMisc = tab:Section("MISC", "Right")
    secMisc:Toggle("logs_toggle", "Enable Event Logs", config.LOGS, function(state)
        config.LOGS = state
        notify("Settings", "Event Logs: " .. tostring(state), 2)
    end)
    secMisc:Toggle("coin_logs_toggle", "Detailed Coin Logs", config.CoinLogs, function(state) 
        config.CoinLogs = state
        notify("Settings", "Coins Logs: " .. tostring(state), 2)
    end)
    secMisc:Toggle("anti_afk_toggle", "Anti-AFK (Jump)", config.Anti_AFK, function(state)
        config.Anti_AFK = state
        notify("Settings", "Anti-AFK: " .. tostring(state), 2)
    end)
    secMisc:SliderInt("anti_afk_time", "Jump Interval (s)", 1, 300, 60, function(val)
        config.Anti_AFK_Time = val
    end)

    -- [ BOTONES DE ACCIÓN RÁPIDA ]
    local secTP = tab:Section("Instant Actions & TPs", "Right")
    
    secTP:Button("TP to Event", function()
        local character = game.Players.LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.Position = Vector3.new(-353.7116, 32.7624, -1422.9288)
            notify("[Manual Teleport]", "Teleported to Event Area", 2)
        end
    end)

    secTP:Button("TP to Minigame", function()
        local character = game.Players.LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.Position = Vector3.new(-372.1794, 32.7624, -1424.9301)
            notify("[Manual Teleport]", "Teleported to Minigame Entrance", 2)
        end
    end)

    secTP:Button("TP to Boat", function()
        local character = game.Players.LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local boatTop = GetBoatTopInstance()
            if boatTop and boatTop:IsA("BasePart") then
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.Position = boatTop.Position
                notify("[Manual Teleport]", "Teleported to Boat", 2)
            end
        end
    end)
end)

local ScanCooldown = 0.2 
local player = game.Players.LocalPlayer

function GetBoatTopInstance()
    local interiors = workspace:FindFirstChild("Interiors")
    local mainMap = interiors and interiors:FindFirstChild("MainMap!Default")
    local eventFolder = mainMap and mainMap:FindFirstChild("Event")
    local journeyPass = eventFolder and eventFolder:FindFirstChild("JourneyPass")
    local boat = journeyPass and journeyPass:FindFirstChild("Boat")
    if boat then
        local top = boat:FindFirstChild("Top")
        if top and top:IsA("BasePart") then
            return top
        end
    end
    return nil
end

function GetDivePart()
    local interiors = workspace:FindFirstChild("Interiors")
    local mainMap = interiors and interiors:FindFirstChild("MainMap!Default")
    local event = mainMap and mainMap:FindFirstChild("Event")
    local journeyPass = event and event:FindFirstChild("JourneyPass")
    local journeyParts = journeyPass and journeyPass:FindFirstChild("JourneyParts")
    local week2 = journeyParts and journeyParts:FindFirstChild("Week2")
    local divePart = week2 and week2:FindFirstChild("DivePart")
    
    if divePart and divePart:IsA("BasePart") then
        return divePart
    end
    return nil
end

function AreTrashMarkersPresent()
    local interiors = workspace:FindFirstChild("Interiors")
    local mainMap = interiors and interiors:FindFirstChild("MainMap!Default")
    local event = mainMap and mainMap:FindFirstChild("Event")
    local journeyPass = event and event:FindFirstChild("JourneyPass")
    local journeyParts = journeyPass and journeyPass:FindFirstChild("JourneyParts")
    local week2 = journeyParts and journeyParts:FindFirstChild("Week2")
    local trashMarkersFolder = week2 and week2:FindFirstChild("TrashMarkers")
    
    if trashMarkersFolder then
        for _, child in ipairs(trashMarkersFolder:GetChildren()) do
            if child:IsA("BasePart") and child.Transparency < 1 then
                return true
            end
        end
    end
    return false
end

function GetLadderPart()
    local interiors = workspace:FindFirstChild("Interiors")
    local oceanMinigame = interiors and interiors:FindFirstChild("OceanMinigameInterior")
    local ladder = oceanMinigame and oceanMinigame:FindFirstChild("Ladder")
    local part = ladder and ladder:FindFirstChild("Part")
    
    if part and part:IsA("BasePart") then
        return part
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
                    EventLog("Anti-AFK")
                end
                elapsed = 0
            end
        else
            elapsed = 0
        end
    end
end)

-- [ MAIN LOOP MÁQUINA DE ESTADOS ]
task.spawn(function()
    while true do
        if not config.Beam_AutoFarm and not config.Token_AutoFarm and not config.Trash_AutoFarm and not config.Boat_AutoFarm then 
            task.wait(0.5) 
            continue 
        end
        
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        
        if hrp then
            
            local ladderPart = GetLadderPart()
            local boatTop = GetBoatTopInstance()
            local divePart = GetDivePart()

            -- [0] FILTRO DE FALSOS POSITIVOS (Doble Chequeo de 1 segundo)
            local isMinigameReady = false
            if config.Trash_AutoFarm and divePart then
                if AreTrashMarkersPresent() then
                    EventLog("Marker detected. Waiting 1s to verify false positive...")
                    task.wait(1)
                    if AreTrashMarkersPresent() then
                        isMinigameReady = true
                    else
                        EventLog("Ignored false positive marker blip.")
                    end
                end
            end

            -- [ESTADO 1] ADENTRO DEL MINIJUEGO (Recuperación por Fallback)
            if ladderPart then
                EventLog("Resuming minigame from inside (Fallback Cycle 1)")
                
                -- BOLSAS
                local isFarmingBags = true
                local emptyChecks = 0
                while isFarmingBags and GetLadderPart() do
                    local trashFolder = workspace:FindFirstChild("Trash")
                    if not trashFolder then 
                        emptyChecks = emptyChecks + 1
                        if emptyChecks >= 15 then isFarmingBags = false; break end
                        task.wait(0.2); continue
                    end

                    local bags = {}
                    for _, child in ipairs(trashFolder:GetChildren()) do
                        if child.Name == "TrashBag" then table.insert(bags, child) end
                    end

                    if #bags > 0 then
                        emptyChecks = 0 
                        for _, bag in ipairs(bags) do
                            if bag and bag.Parent then
                                local targetPos = nil
                                if bag:IsA("BasePart") then targetPos = bag.Position
                                elseif bag:IsA("Model") then
                                    local primary = bag.PrimaryPart or bag:FindFirstChildWhichIsA("BasePart")
                                    if primary then targetPos = primary.Position end
                                end

                                if targetPos then
                                    hrp.Velocity = Vector3.new(0, 0, 0)
                                    hrp.Position = targetPos + Vector3.new(0, 1.5, 0)
                                    task.wait(0.1)
                                    if keypress and keyrelease then
                                        keypress(0x45)
                                        task.wait(0.02)
                                        keyrelease(0x45)
                                    end
                                    task.wait(0.1)
                                end
                            end
                        end
                    else
                        emptyChecks = emptyChecks + 1
                        if emptyChecks >= 15 then isFarmingBags = false end
                    end
                    task.wait(0.2)
                end

                -- MONEDAS (SUCCIÓN AL JUGADOR)
                if GetLadderPart() then
                    EventLog("Waiting 10 seconds for coins...")
                    task.wait(10) 
                    local tokens = {}
                    for _, child in ipairs(workspace:GetChildren()) do
                        if child.Name == "TokenPickup" then
                            local col = child:FindFirstChild("Collider") or child
                            if col:IsA("BasePart") then table.insert(tokens, col) end
                        end
                    end

                    if #tokens > 0 then
                        EventLog("Bringing coins to player in minigame")
                        for _, token in ipairs(tokens) do
                            if token and token.Parent and token:IsA("BasePart") then
                                token.CFrame = hrp.CFrame
                            end
                        end
                        task.wait(0.5)
                    end
                    task.wait(2)
                end

                -- SALIDA
                EventLog("Minigame finished, teleporting to ladder to exit")
                while GetLadderPart() do
                    local currentLadder = GetLadderPart()
                    hrp.Velocity = Vector3.new(0, 0, 0)
                    hrp.Position = currentLadder.Position + Vector3.new(0, 1.5, 0)
                    task.wait(1)
                    PerformSafeClick()
                    task.wait(2)
                end
                continue 
            end

            -- [ESTADO 2] INICIO DE EVENTO: CICLO DOBLE EXACTO
            if isMinigameReady and divePart then
                EventLog("Minigame confirmed! Starting Double Cycle.")
                
                -- ================== CICLO 1 ==================
                local entryAttempts1 = 0
                while config.Trash_AutoFarm and not GetLadderPart() and entryAttempts1 < 10 do
                    local dp = GetDivePart()
                    if dp then
                        hrp.Velocity = Vector3.new(0, 0, 0)
                        hrp.Position = dp.Position + Vector3.new(0, 1.5, 0)
                        task.wait(1)
                        PerformSafeClick()
                        task.wait(2)
                    end
                    entryAttempts1 = entryAttempts1 + 1
                end

                if GetLadderPart() then
                    EventLog("Cycle 1: Inside successfully.")
                    task.wait(2) 

                    local isFarmingBags = true
                    local emptyChecks = 0
                    while isFarmingBags and GetLadderPart() do
                        local trashFolder = workspace:FindFirstChild("Trash")
                        if not trashFolder then 
                            emptyChecks = emptyChecks + 1
                            if emptyChecks >= 15 then isFarmingBags = false; break end
                            task.wait(0.2); continue
                        end

                        local bags = {}
                        for _, child in ipairs(trashFolder:GetChildren()) do
                            if child.Name == "TrashBag" then table.insert(bags, child) end
                        end

                        if #bags > 0 then
                            emptyChecks = 0 
                            for _, bag in ipairs(bags) do
                                if bag and bag.Parent then
                                    local targetPos = nil
                                    if bag:IsA("BasePart") then targetPos = bag.Position
                                    elseif bag:IsA("Model") then
                                        local primary = bag.PrimaryPart or bag:FindFirstChildWhichIsA("BasePart")
                                        if primary then targetPos = primary.Position end
                                    end

                                    if targetPos then
                                        hrp.Velocity = Vector3.new(0, 0, 0)
                                        hrp.Position = targetPos + Vector3.new(0, 1.5, 0)
                                        task.wait(0.1)
                                        if keypress and keyrelease then
                                            keypress(0x45)
                                            task.wait(0.02)
                                            keyrelease(0x45)
                                        end
                                        task.wait(0.1)
                                    end
                                end
                            end
                        else
                            emptyChecks = emptyChecks + 1
                            if emptyChecks >= 15 then isFarmingBags = false end
                        end
                        task.wait(0.2)
                    end

                    if GetLadderPart() then
                        EventLog("Cycle 1: Bags collected. Waiting 10s for coins.")
                        task.wait(10)
                        local tokens = {}
                        for _, child in ipairs(workspace:GetChildren()) do
                            if child.Name == "TokenPickup" then
                                local col = child:FindFirstChild("Collider") or child
                                if col:IsA("BasePart") then table.insert(tokens, col) end
                            end
                        end

                        if #tokens > 0 then
                            EventLog("Cycle 1: Bringing coins to player")
                            for _, token in ipairs(tokens) do
                                if token and token.Parent and token:IsA("BasePart") then
                                    token.CFrame = hrp.CFrame
                                end
                            end
                            task.wait(0.5)
                        end
                        task.wait(2)
                    end

                    -- SALIDA CICLO 1
                    EventLog("Cycle 1: Exiting...")
                    while GetLadderPart() do
                        local currentLadder = GetLadderPart()
                        hrp.Velocity = Vector3.new(0, 0, 0)
                        hrp.Position = currentLadder.Position + Vector3.new(0, 1.5, 0)
                        task.wait(1)
                        PerformSafeClick()
                        task.wait(2)
                    end

                    -- ================== CICLO 2 ==================
                    EventLog("Cycle 1 complete. Attempting Cycle 2...")
                    task.wait(2) 

                    local entryAttempts2 = 0
                    while config.Trash_AutoFarm and not GetLadderPart() and entryAttempts2 < 10 do
                        local dp = GetDivePart()
                        if dp then
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            hrp.Position = dp.Position + Vector3.new(0, 1.5, 0)
                            task.wait(1)
                            PerformSafeClick()
                            task.wait(2)
                        end
                        entryAttempts2 = entryAttempts2 + 1
                    end

                    if GetLadderPart() then
                        EventLog("Cycle 2: Inside successfully. Waiting 5s for coins.")
                        task.wait(5)

                        -- MONEDAS CICLO 2 (Recolección rápida por succión)
                        if GetLadderPart() then
                            local tokens = {}
                            for _, child in ipairs(workspace:GetChildren()) do
                                if child.Name == "TokenPickup" then
                                    local col = child:FindFirstChild("Collider") or child
                                    if col:IsA("BasePart") then table.insert(tokens, col) end
                                end
                            end

                            if #tokens > 0 then
                                EventLog("Cycle 2: Bringing leftover coins to player")
                                for _, token in ipairs(tokens) do
                                    if token and token.Parent and token:IsA("BasePart") then
                                        token.CFrame = hrp.CFrame
                                    end
                                end
                                task.wait(0.5)
                            end
                            task.wait(2)
                        end
                        
                        -- SALIDA CICLO 2
                        EventLog("Cycle 2: Exiting...")
                        while GetLadderPart() do
                            local currentLadder = GetLadderPart()
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            hrp.Position = currentLadder.Position + Vector3.new(0, 1.5, 0)
                            task.wait(1)
                            PerformSafeClick()
                            task.wait(2)
                        end
                        EventLog("Cycle 2 Complete.")
                    end
                end
                continue 
            end

            -- [ESTADO 3 & 4] BOTE, O EVENTO BASE
            if boatTop or divePart then
                
                -- Recolección Global de Monedas y Rayos en MainMap/Event
                local currentTargets = {}
                for _, child in ipairs(workspace:GetChildren()) do
                    if config.Beam_AutoFarm and child.Name == "SmallLightBeam" then
                        if child:IsA("BasePart") then table.insert(currentTargets, {Part = child, Type = "Beam"})
                        elseif child:IsA("Model") then
                            local primary = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
                            if primary then table.insert(currentTargets, {Part = primary, Type = "Beam"}) end
                        end
                    elseif config.Token_AutoFarm and child.Name == "TokenPickup" then
                        local col = child:FindFirstChild("Collider") or child
                        if col:IsA("BasePart") then table.insert(currentTargets, {Part = col, Type = "Token"}) end
                    end
                end
                
                if #currentTargets > 0 then
                    for _, item in ipairs(currentTargets) do
                        if config.Trash_AutoFarm and AreTrashMarkersPresent() then break end 
                        
                        local target = item.Part
                        if target and target.Parent and target:IsA("BasePart") then
                            -- Usamos el CFrame Magnet que descubriste para Token y Beams!
                            target.CFrame = hrp.CFrame
                        end
                    end
                    task.wait(config.Token_Cooldown)
                else
                    -- ANCLAJES DE DESCANSO
                    if boatTop and config.Boat_AutoFarm then
                        hrp.Velocity = Vector3.new(0, 0, 0)
                        hrp.Position = boatTop.Position + Vector3.new(0, -0.5, 0)
                    elseif divePart and config.Idle_TP then 
                        hrp.Velocity = Vector3.new(0, 0, 0)
                        hrp.Position = Vector3.new(-353.7116, 32.7624, -1422.9288)
                    end
                end
                
                task.wait(0.05)
                continue
            end

            -- [ESTADO 5] ESTAMOS EN EL MAIN MAP U OTRA ZONA (No Boat, No Dive, No Ladder)
            EventLog("Event Map not detected. Attempting UI navigation to Event...")
            Tp2Event()
            task.wait(3) 
        end
        task.wait(ScanCooldown)
    end
end)
