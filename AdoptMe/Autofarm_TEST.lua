--[[
[+] Adopt Me AutoFarm GUI V1.16
[+] [FIXED] Trash Bag farming breaking early due to load latency. Added a tolerance system (emptyChecks).
[+] [IMPROVED] Trash Bag detection now supports both BaseParts and Models.
[+] [NEW] UI Notifications for Toggles & Buttons.
[+] [NEW] Advanced Event Logging for Minigame Stages.
]]

local textprint = "--- ADOPT ME AUTO-FARM V1.16 (Matcha Absolute Clicks Edition)" 
local config = {
    Beam_AutoFarm = false,
    Beam_Cooldown = 0.05,
    
    Token_AutoFarm = true,
    Token_Cooldown = 0.05,
    
    Boat_AutoFarm = true,
    Trash_AutoFarm = true,
    
    Anti_AFK = false,
    Anti_AFK_Time = 60,
    
    LOGS = true, 
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

UI.AddTab("Event AF", function(tab)
    local sec = tab:Section("Configuration", "Left")
    sec:Toggle("boat_toggle", "Boat Idle & Token Farm", config.Boat_AutoFarm, function(state)
        config.Boat_AutoFarm = state
        notify("[AutoFarm]", "Boat Idle: " .. tostring(state),2)
    end)
    sec:Toggle("token_toggle", "Token/Coins AutoFarm", config.Token_AutoFarm, function(state)
        config.Token_AutoFarm = state
        notify("[AutoFarm]", "Token AutoFarm: " .. tostring(state),2)
    end)
    sec:SliderInt("token_cooldown", "Token TP Cooldown (ms)", 1, 100, 5, function(val)
        config.Token_Cooldown = val / 100
    end)
    sec:Toggle("beam_toggle", "Light Beam AutoFarm", config.Beam_AutoFarm, function(state)
        config.Beam_AutoFarm = state
        notify("[AutoFarm]", "Beam AutoFarm: " .. tostring(state),2)
    end)
    sec:SliderInt("beam_cooldown", "Beam TP Cooldown (ms)", 1, 100, 5, function(val)
        config.Beam_Cooldown = val / 100
    end)
    sec:Toggle("trash_toggle", "Trash Bags AutoFarm", config.Trash_AutoFarm, function(state)
        config.Trash_AutoFarm = state
        notify("[AutoFarm]", "Trash Minigame: " .. tostring(state),2)
    end)
    
    -- [ SECCIÓN MISC ]
    local secMisc = tab:Section("MISC", "Right")
    secMisc:Toggle("logs_toggle", "Enable Event Logs", config.LOGS, function(state)
        config.LOGS = state
        notify("Settings", "Event Logs: " .. tostring(state),2)
    end)
    secMisc:Toggle("coin_logs_toggle", "Detailed Coin Logs", config.CoinLogs, function(state) 
        config.CoinLogs = state
        notify("Settings", "Coins Logs: " .. tostring(state),2)
    end)
    secMisc:Toggle("anti_afk_toggle", "Anti-AFK (Jump)", config.Anti_AFK, function(state)
        config.Anti_AFK = state
        notify("Settings", "Anti-AFK: " .. tostring(state),2)
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
            notify("[Manual Teleport]", "Teleported to Event Area",2)
        end
    end)

    secTP:Button("TP to Minigame", function()
        local character = game.Players.LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.Position = Vector3.new(-372.1794, 32.7624, -1424.9301)
            notify("[Manual Teleport]", "Teleported to Minigame Entrance",2)
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
                notify("[Manual Teleport]", "Teleported to Boat",2)
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
                end
                elapsed = 0
            end
        else
            elapsed = 0
        end
    end
end)

-- [ MAIN LOOP ]
task.spawn(function()
    while true do
        if not config.Beam_AutoFarm and not config.Token_AutoFarm and not config.Trash_AutoFarm and not config.Boat_AutoFarm then 
            task.wait(0.5) 
            continue 
        end
        
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        
        if hrp then
            
            -------------- [1] SECUENCIA DIVE PART CON MOUSE (ACTIVADO POR TRASH MARKERS)
            local isMinigameReady = AreTrashMarkersPresent()

            if config.Trash_AutoFarm and isMinigameReady then
                local divePart = GetDivePart()
                if divePart then
                    
                    EventLog("Trashmarkers appeared, teleporting to diving part minigame")
                    
                    -- =======================================================
                    -- CICLO 1: FARMEAR BOLSAS Y MONEDAS
                    -- =======================================================
                    
                    -- Entrar al minijuego
                    hrp.Velocity = Vector3.new(0, 0, 0)
                    hrp.Position = divePart.Position + Vector3.new(0, 1.5, 0)
                    
                    task.wait(1)
                    PerformSafeClick() -- Click de entrada

                    task.wait(5) -- Esperar 5s adentro para asegurar que cargue

                    local ladderPart = GetLadderPart()
                    if ladderPart then
                        EventLog("Ladder found, starting trash farm (Cycle 1)")
                        
                        -- Lógica de recolección de bolsas con TOLERANCIA
                        local isFarmingBags = true
                        local emptyChecks = 0

                        while isFarmingBags do
                            local trashFolder = workspace:FindFirstChild("Trash")
                            
                            -- Si la carpeta Trash tarda en cargar o no existe aún
                            if not trashFolder then 
                                emptyChecks = emptyChecks + 1
                                if emptyChecks >= 15 then -- Espera hasta ~3 segundos
                                    isFarmingBags = false
                                    break 
                                end
                                task.wait(0.2)
                                continue
                            end

                            local bags = {}
                            for _, child in ipairs(trashFolder:GetChildren()) do
                                if child.Name == "TrashBag" then
                                    table.insert(bags, child)
                                end
                            end

                            if #bags > 0 then
                                emptyChecks = 0 -- Reseteamos contador porque encontramos bolsas
                                for _, bag in ipairs(bags) do
                                    if bag and bag.Parent then
                                        -- Detectar si es Model o BasePart
                                        local targetPos = nil
                                        if bag:IsA("BasePart") then
                                            targetPos = bag.Position
                                        elseif bag:IsA("Model") then
                                            local primary = bag.PrimaryPart or bag:FindFirstChildWhichIsA("BasePart")
                                            if primary then targetPos = primary.Position end
                                        end

                                        if targetPos then
                                            hrp.Velocity = Vector3.new(0, 0, 0)
                                            hrp.Position = targetPos + Vector3.new(0, 1.5, 0)
                                            task.wait(0.2)
                                            
                                            if keypress and keyrelease then
                                                keypress(0x45)
                                                task.wait(0.05)
                                                keyrelease(0x45)
                                            end
                                            task.wait(0.2)
                                        end
                                    end
                                end
                            else
                                -- Si la carpeta existe pero está vacía
                                emptyChecks = emptyChecks + 1
                                if emptyChecks >= 15 then -- Confirmamos 15 veces seguidas que ya no hay bolsas
                                    isFarmingBags = false 
                                end
                            end
                            task.wait(0.2)
                        end

                        EventLog("No bags found, waiting 10 seconds for coins")
                        task.wait(10) -- Esperar monedas

                        -- Recoger monedas
                        local tokens = {}
                        for _, child in ipairs(workspace:GetChildren()) do
                            if child.Name == "TokenPickup" then
                                local col = child:FindFirstChild("Collider") or child
                                if col:IsA("BasePart") then table.insert(tokens, col) end
                            end
                        end

                        if #tokens > 0 then
                            EventLog("Collecting coins in minigame")
                            for _, token in ipairs(tokens) do
                                if token and token.Parent and token:IsA("BasePart") then
                                    local successPos, targetPos = pcall(function() return token.Position end)
                                    if successPos and typeof(targetPos) == "Vector3" then
                                        hrp.Velocity = Vector3.new(0, -10, 0)
                                        hrp.Position = targetPos + Vector3.new(0, 2.5, 0)
                                        task.wait(config.Token_Cooldown)
                                    end
                                end
                            end
                        end

                        task.wait(2) -- Esperar después de las monedas
                        EventLog("Minigame finished, teleporting to ladder to exit (Cycle 1)")

                        -- Salida 1
                        while true do
                            local currentLadder = GetLadderPart()
                            if not currentLadder then break end -- Salió exitosamente

                            hrp.Velocity = Vector3.new(0, 0, 0)
                            hrp.Position = currentLadder.Position + Vector3.new(0, 1.5, 0)
                            
                            task.wait(1)
                            PerformSafeClick() -- Click de salida
                            task.wait(2)
                        end
                    end
                    
                    -- =======================================================
                    -- CICLO 2: VOLVER A ENTRAR, ESPERAR 10s Y SALIR
                    -- =======================================================
                    
                    EventLog("Cycle 1 complete. Teleporting to diving part for Cycle 2")
                    task.wait(1) 
                    
                    local divePart2 = GetDivePart()
                    if divePart2 then
                        -- Entrar de nuevo
                        hrp.Velocity = Vector3.new(0, 0, 0)
                        hrp.Position = divePart2.Position + Vector3.new(0, 1.5, 0)
                        
                        task.wait(1)
                        PerformSafeClick() -- Click de entrada
                        
                        EventLog("Ladder found, waiting 5 seconds (Cycle 2)")
                        task.wait(5)
                        -- Lógica de recolección de bolsas con TOLERANCIA
                        local isFarmingBags = true
                        local emptyChecks = 0

                        while isFarmingBags do
                            local trashFolder = workspace:FindFirstChild("Trash")
                            
                            -- Si la carpeta Trash tarda en cargar o no existe aún
                            if not trashFolder then 
                                emptyChecks = emptyChecks + 1
                                if emptyChecks >= 15 then -- Espera hasta ~3 segundos
                                    isFarmingBags = false
                                    break 
                                end
                                task.wait(0.2)
                                continue
                            end

                            local bags = {}
                            for _, child in ipairs(trashFolder:GetChildren()) do
                                if child.Name == "TrashBag" then
                                    table.insert(bags, child)
                                end
                            end

                            if #bags > 0 then
                                emptyChecks = 0 -- Reseteamos contador porque encontramos bolsas
                                for _, bag in ipairs(bags) do
                                    if bag and bag.Parent then
                                        -- Detectar si es Model o BasePart
                                        local targetPos = nil
                                        if bag:IsA("BasePart") then
                                            targetPos = bag.Position
                                        elseif bag:IsA("Model") then
                                            local primary = bag.PrimaryPart or bag:FindFirstChildWhichIsA("BasePart")
                                            if primary then targetPos = primary.Position end
                                        end

                                        if targetPos then
                                            hrp.Velocity = Vector3.new(0, 0, 0)
                                            hrp.Position = targetPos + Vector3.new(0, 1.5, 0)
                                            task.wait(0.2)
                                            
                                            if keypress and keyrelease then
                                                keypress(0x45)
                                                task.wait(0.05)
                                                keyrelease(0x45)
                                            end
                                            task.wait(0.2)
                                        end
                                    end
                                end
                            else
                                -- Si la carpeta existe pero está vacía
                                emptyChecks = emptyChecks + 1
                                if emptyChecks >= 15 then -- Confirmamos 15 veces seguidas que ya no hay bolsas
                                    isFarmingBags = false 
                                end
                            end
                            task.wait(0.2)
                        end
                        task.wait(2)
                                                -- Recoger monedas
                        local tokens = {}
                        for _, child in ipairs(workspace:GetChildren()) do
                            if child.Name == "TokenPickup" then
                                local col = child:FindFirstChild("Collider") or child
                                if col:IsA("BasePart") then table.insert(tokens, col) end
                            end
                        end

                        if #tokens > 0 then
                            EventLog("Collecting coins in minigame")
                            for _, token in ipairs(tokens) do
                                if token and token.Parent and token:IsA("BasePart") then
                                    local successPos, targetPos = pcall(function() return token.Position end)
                                    if successPos and typeof(targetPos) == "Vector3" then
                                        hrp.Velocity = Vector3.new(0, -10, 0)
                                        hrp.Position = targetPos + Vector3.new(0, 2.5, 0)
                                        task.wait(config.Token_Cooldown)
                                    end
                                end
                            end
                        end
                        task.wait(5)
                        EventLog("Minigame finished, teleporting to ladder to exit (Cycle 2)")
                        -- Salida 2
                        while true do
                            local currentLadder2 = GetLadderPart()
                            if not currentLadder2 then break end -- Salió exitosamente
                            
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            hrp.Position = currentLadder2.Position + Vector3.new(0, 1.5, 0)
                            
                            task.wait(1)
                            PerformSafeClick() -- Click de salida
                            task.wait(2)
                        end
                    end

                    EventLog("Cycle 2 complete. Returning to Boat/Idle logic.")
                    continue 
                end
            end
            
            -------------- [2] BOAT IDLE & TOKEN LOGIC
            local boatTop = GetBoatTopInstance()

            if config.Boat_AutoFarm and boatTop then
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
                        if config.Trash_AutoFarm and AreTrashMarkersPresent() then break end 
                        
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
                    local successBoat, bPos = pcall(function() return boatTop.Position end)
                    if successBoat and typeof(bPos) == "Vector3" and boatTop.Parent and hrp then
                        hrp.Velocity = Vector3.new(0, 0, 0)
                        hrp.Position = bPos + Vector3.new(0, -0.5, 0)
                    end
                end
                
                task.wait(0.05)
                continue
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
                    if config.Trash_AutoFarm and AreTrashMarkersPresent() then break end
                    
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
