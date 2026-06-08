--[[
[+] Adopt Me AutoFarm GUI V1.3.6
+ Added Dropped Items AutoFarm (AdminAbuseItem + AdminAbuseBucks magnet loop)
+ Added Collect All Tokens button
+ Added Collect All Dropped Items button
+ Added Toggle for Event Idle TP (prevents automatic grounding when targets are clear)
+ Added Auto TP Event Toggle (prevents constant UI teleports)

+ Fixed Cycle being interrupted by by Boat
+ Added Minigame Cycle 2
+ Fixed issue where coins could be left behind

- Reduced Cycle 2 token wait time from 10s to 5s
]]

local textprint = "--- ADOPT ME AUTO-FARM V1.3.6 (Stable + Boat Fix)"
local config = {
    Boat_AutoFarm = true,
    Trash_AutoFarm = true,
    Token_AutoFarm = true,
    Token_Cooldown = 0.05,

    Dropped_Items_AutoFarm = false,
    Drop_Cooldown = 0.05,

    Idle_TP = true,
    Auto_TP_Event = false,

    Anti_AFK = true,
    Anti_AFK_Time = 60,

    LOGS = true,
    CoinLogs = false
}

local stuckTokens = setmetatable({}, {__mode = "k"})
local tokenAttempts = setmetatable({}, {__mode = "k"})
local cycleInterrupted = false
local wasEjectedFromCycle1 = false

local function EventLog(msg, errr)
    if config.LOGS then
        if errr == 1 then
            error("--- [ERR] " .. msg)
        else
            warn("--- [LOG] " .. msg)
        end
    end
end

local function PerformSafeClick()
    if mousemoveabs and mouse1click then
        mousemoveabs(1423, 951)
        task.wait(0.1)
        mousemoveabs(1423, 952)
        task.wait(0.5)
        mouse1click()
    end
end

local function Tp2Event()
    if mousemoveabs and mouse1click then
        mousemoveabs(1284, 1483)
        task.wait(0.1)
        mousemoveabs(1284, 1482)
        task.wait(0.5)
        mouse1click()
        task.wait(0.5)
        mousemoveabs(1069, 1260)
        task.wait(0.1)
        mousemoveabs(1069, 1261)
        task.wait(0.5)
        mouse1click()
        task.wait(0.5)
        mousemoveabs(1193, 1035)
        task.wait(0.1)
        mousemoveabs(1193, 1036)
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
        notify("[AutoFarm]", "Trash AF: " .. tostring(state), 2)
    end)
    sec:Toggle("token_toggle", "Token/Coins AutoFarm", config.Token_AutoFarm, function(state)
        config.Token_AutoFarm = state
        notify("[AutoFarm]", "Token AF: " .. tostring(state), 2)
    end)
    sec:Toggle("idle_tp_toggle", "TP to Event Idle Point", config.Idle_TP, function(state)
        config.Idle_TP = state
        notify("[AutoFarm]", "Event Idle: " .. tostring(state), 2)
    end)
    sec:Toggle("auto_tp_event", "Auto UI TP to Event", config.Auto_TP_Event, function(state)
        config.Auto_TP_Event = state
        notify("[AutoFarm]", "Auto Tp 2 Event: " .. tostring(state), 2)
    end)
    sec:SliderInt("token_cooldown", "Token TP Cooldown (ms)", 1, 100, 5, function(val)
        config.Token_Cooldown = val / 100
    end)
    sec:Toggle("dropped_items_toggle", "Collect Dropped Items", config.Dropped_Items_AutoFarm, function(state)
        config.Dropped_Items_AutoFarm = state
        notify("[AutoFarm]", "Dropped Items: " .. tostring(state), 2)
    end)
    sec:SliderInt("drop_cooldown", "Dropped Items Cooldown (ms)", 1, 100, 5, function(val)
        config.Drop_Cooldown = val / 100
    end)

    local secMisc = tab:Section("MISC", "Right")
    secMisc:Toggle("logs_toggle", "Enable Event Logs", config.LOGS, function(state)
        config.LOGS = state
        notify("[MISC]", "Logs: " .. tostring(state), 2)
    end)
    secMisc:Toggle("coin_logs_toggle", "Detailed Coin Logs", config.CoinLogs, function(state)
        config.CoinLogs = state
        notify("[MISC]", "Coin Logs: " .. tostring(state), 2)
    end)
    secMisc:Toggle("anti_afk_toggle", "Anti-AFK (Jump)", config.Anti_AFK, function(state)
        config.Anti_AFK = state
        notify("[MISC]", "Anti-AFK: " .. tostring(state), 2)
    end)
    secMisc:SliderInt("anti_afk_time", "Jump Interval (s)", 1, 300, 60, function(val)
        config.Anti_AFK_Time = val
    end)

    local secTP = tab:Section("Instant Actions & TPs", "Right")

    secTP:Button("TP to Event", function()
        local character = game.Players.LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.Position = Vector3.new(-353.7116, 32.7624, -1422.9288)
            notify("[MANUAL TP]", "Teleported to Event", 2)
        end
    end)

    secTP:Button("TP to Minigame", function()
        local character = game.Players.LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.Position = Vector3.new(-372.1794, 32.7624, -1424.9301)
            notify("[MANUAL TP]", "Teleported to Minigame", 2)
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
                notify("[MANUAL TP]", "Teleported to Boat", 2)
            end
        end
    end)

    secTP:Button("Collect All Tokens", function()
        local character = game.Players.LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, child in ipairs(workspace:GetChildren()) do
                if child.Name == "TokenPickup" then
                    local col = child:FindFirstChild("Collider") or child
                    if col and col:IsA("BasePart") and col.Parent then
                        col.CFrame = hrp.CFrame
                    end
                end
            end
            notify("[Manual]", "All tokens collected", 2)
        end
    end)

    secTP:Button("Collect All Dropped Items", function()
        local character = game.Players.LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, child in ipairs(workspace:GetChildren()) do
                if child.Name == "AdminAbuseItem" or child.Name == "AdminAbuseBucks" then
                    local visual = child:FindFirstChild("Visual")
                    local part = visual and visual:FindFirstChild("Part")
                    if part and part:IsA("BasePart") then
                        part.CFrame = hrp.CFrame
                    end
                    local col = child:FindFirstChild("Collider")
                    if col and col:IsA("BasePart") then
                        col.CFrame = hrp.CFrame
                    end
                end
            end
            notify("[Manual]", "All dropped items collected", 2)
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
        if top and top:IsA("BasePart") then return top end
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
    if divePart and divePart:IsA("BasePart") then return divePart end
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
            if child:IsA("BasePart") and child.Transparency < 1 then return true end
        end
    end
    return false
end

function GetLadderPart()
    local interiors = workspace:FindFirstChild("Interiors")
    local oceanMinigame = interiors and interiors:FindFirstChild("OceanMinigameInterior")
    local ladder = oceanMinigame and oceanMinigame:FindFirstChild("Ladder")
    local part = ladder and ladder:FindFirstChild("Part")
    if part and part:IsA("BasePart") then return part end
    return nil
end

print(textprint)

-- [ DROPPED ITEMS MAGNET LOOP ]
task.spawn(function()
    while true do
        if config.Dropped_Items_AutoFarm then
            local character = player.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, child in ipairs(workspace:GetChildren()) do
                    if child.Name == "AdminAbuseItem" or child.Name == "AdminAbuseBucks" then
                        local visual = child:FindFirstChild("Visual")
                        local part = visual and visual:FindFirstChild("Part")
                        if part and part:IsA("BasePart") and part.Parent then
                            part.CFrame = hrp.CFrame
                        end
                        local col = child:FindFirstChild("Collider")
                        if col and col:IsA("BasePart") and col.Parent then
                            col.CFrame = hrp.CFrame
                        end
                    end
                end
            end
        end
        task.wait(0.05)
    end
end)

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

-- [ MAIN LOOP ]
task.spawn(function()
    while true do
        if not config.Dropped_Items_AutoFarm and not config.Token_AutoFarm and not config.Trash_AutoFarm and not config.Boat_AutoFarm then
            task.wait(0.5)
            continue
        end

        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        if hrp then
            local ladderPart = GetLadderPart()
            local boatTop = GetBoatTopInstance()
            local divePart = GetDivePart()

            -- [0] FILTRO DE FALSOS POSITIVOS
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

            -- [ESTADO 1] ADENTRO DEL MINIJUEGO (Fallback)
            if ladderPart then
                EventLog("Resuming minigame from inside (Fallback)")

                local isFarmingBags = true
                local emptyChecks = 0
                while isFarmingBags and GetLadderPart() do
                    if GetBoatTopInstance() then cycleInterrupted = true; break end
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
                            if GetBoatTopInstance() then cycleInterrupted = true; break end
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
                                        keypress(0x45); task.wait(0.02); keyrelease(0x45)
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

                if not cycleInterrupted and GetLadderPart() then
                    EventLog("Waiting 10 seconds for coins...")
                    task.wait(10)
                    local coinScanActive = true
                    while coinScanActive and GetLadderPart() do
                        if GetBoatTopInstance() then cycleInterrupted = true; break end
                        local found = false
                        for _, child in ipairs(workspace:GetChildren()) do
                            if child.Name == "TokenPickup" then
                                local col = child:FindFirstChild("Collider") or child
                                if col and col:IsA("BasePart") and col.Parent then
                                    local ok, pos = pcall(function() return col.Position end)
                                    if ok and typeof(pos) == "Vector3" then
                                        hrp.Velocity = Vector3.new(0, -10, 0)
                                        hrp.Position = pos + Vector3.new(0, 2.5, 0)
                                        task.wait(config.Token_Cooldown)
                                        found = true
                                        break
                                    end
                                end
                            end
                        end
                        if not found then coinScanActive = false end
                    end
                    task.wait(2)
                end

                if not cycleInterrupted then
                    EventLog("Exiting minigame...")
                    while GetLadderPart() do
                        local currentLadder = GetLadderPart()
                        hrp.Velocity = Vector3.new(0, 0, 0)
                        hrp.Position = currentLadder.Position + Vector3.new(0, 1.5, 0)
                        task.wait(1)
                        PerformSafeClick()
                        task.wait(2)
                    end
                else
                    EventLog("Cycle interrupted by Boat. Returning to main loop.")
                    cycleInterrupted = false
                end
                continue
            end

            -- [ESTADO 2] CICLO DOBLE
            if isMinigameReady and divePart then
                EventLog("Minigame confirmed! Starting Double Cycle.")
                cycleInterrupted = false

                -- ================== CICLO 1 ==================
                local entryAttempts1 = 0
                local entryAttempts1 = 0
                while config.Trash_AutoFarm and not GetLadderPart() and entryAttempts1 < 3 do
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

                if not cycleInterrupted and GetLadderPart() then
                    EventLog("Cycle 1: Inside successfully.")
                    task.wait(2)

                    local isFarmingBags = true
                    local emptyChecks = 0
                    while isFarmingBags and GetLadderPart() do
                        if GetBoatTopInstance() then cycleInterrupted = true; break end
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
                                if GetBoatTopInstance() then cycleInterrupted = true; break end
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
                                            keypress(0x45); task.wait(0.02); keyrelease(0x45)
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

                    if not cycleInterrupted and GetLadderPart() then
                        EventLog("Cycle 1: Bags collected. Waiting 10s for coins.")
                        task.wait(10)
                        local coinScanActive = true
                        while coinScanActive and GetLadderPart() do
                            if GetBoatTopInstance() then cycleInterrupted = true; break end
                            local found = false
                            for _, child in ipairs(workspace:GetChildren()) do
                                if child.Name == "TokenPickup" then
                                    local col = child:FindFirstChild("Collider") or child
                                    if col and col:IsA("BasePart") and col.Parent then
                                        local ok, pos = pcall(function() return col.Position end)
                                        if ok and typeof(pos) == "Vector3" then
                                            hrp.Velocity = Vector3.new(0, -10, 0)
                                            hrp.Position = pos + Vector3.new(0, 2.5, 0)
                                            task.wait(config.Token_Cooldown)
                                            found = true
                                            break
                                        end
                                    end
                                end
                            end
                            if not found then coinScanActive = false end
                        end
                        task.wait(2)
                    end

                    if not cycleInterrupted then
                        EventLog("Cycle 1: Exiting...")
                        while GetLadderPart() do
                            local currentLadder = GetLadderPart()
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            hrp.Position = currentLadder.Position + Vector3.new(0, 1.5, 0)
                            task.wait(1)
                            PerformSafeClick()
                            task.wait(2)
                        end
                    else
                        -- Nos sacaron antes de llegar a ladder
                        wasEjectedFromCycle1 = true
                    end
                end

                -- ================== CICLO 2 ==================
                if not cycleInterrupted and not wasEjectedFromCycle1 then
                    EventLog("Cycle 1 complete. Attempting Cycle 2...")
                    task.wait(2)

                    local entryAttempts2 = 0
                    while config.Trash_AutoFarm and not GetLadderPart() and entryAttempts2 < 3 and not AreTrashMarkersPresent() do
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

                    if not cycleInterrupted and GetLadderPart() then
                        EventLog("Cycle 2: Inside successfully. Starting farm routine.")
                        task.wait(2)

                        local isFarmingBags2 = true
                        local emptyChecks2 = 0
                        while isFarmingBags2 and GetLadderPart() do
                            if GetBoatTopInstance() then cycleInterrupted = true; break end
                            local trashFolder = workspace:FindFirstChild("Trash")
                            if not trashFolder then
                                emptyChecks2 = emptyChecks2 + 1
                                if emptyChecks2 >= 15 then isFarmingBags2 = false; break end
                                task.wait(0.2); continue
                            end

                            local bags = {}
                            for _, child in ipairs(trashFolder:GetChildren()) do
                                if child.Name == "TrashBag" then table.insert(bags, child) end
                            end

                            if #bags > 0 then
                                emptyChecks2 = 0
                                for _, bag in ipairs(bags) do
                                    if GetBoatTopInstance() then cycleInterrupted = true; break end
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
                                                keypress(0x45); task.wait(0.02); keyrelease(0x45)
                                            end
                                            task.wait(0.1)
                                        end
                                    end
                                end
                            else
                                emptyChecks2 = emptyChecks2 + 1
                                if emptyChecks2 >= 15 then isFarmingBags2 = false end
                            end
                            task.wait(0.2)
                        end

                        if not cycleInterrupted and GetLadderPart() then
                            EventLog("Cycle 2: Bags checked. Waiting 5s for coins.")
                            task.wait(5)
                            local coinScanActive = true
                            while coinScanActive and GetLadderPart() do
                                if GetBoatTopInstance() then cycleInterrupted = true; break end
                                local found = false
                                for _, child in ipairs(workspace:GetChildren()) do
                                    if child.Name == "TokenPickup" then
                                        local col = child:FindFirstChild("Collider") or child
                                        if col and col:IsA("BasePart") and col.Parent then
                                            local ok, pos = pcall(function() return col.Position end)
                                            if ok and typeof(pos) == "Vector3" then
                                                hrp.Velocity = Vector3.new(0, -10, 0)
                                                hrp.Position = pos + Vector3.new(0, 2.5, 0)
                                                task.wait(config.Token_Cooldown)
                                                found = true
                                                break
                                            end
                                        end
                                    end
                                end
                                if not found then coinScanActive = false end
                            end
                            task.wait(2)
                        end

                        if not cycleInterrupted then
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
                end

                if cycleInterrupted then
                    EventLog("Cycle interrupted by Boat. Returning to main loop.")
                    cycleInterrupted = false
                end
                wasEjectedFromCycle1 = false
                continue
            end

            -- [ESTADO 3 & 4] BOTE O EVENTO BASE
            if boatTop or divePart then
                local currentTargets = {}
                for _, child in ipairs(workspace:GetChildren()) do
                    if config.Token_AutoFarm and child.Name == "TokenPickup" then
                        local col = child:FindFirstChild("Collider") or child
                        if col:IsA("BasePart") and not stuckTokens[child] then
                            table.insert(currentTargets, {Part = col, Type = "Token", ParentObj = child})
                        end
                    end
                end

                if #currentTargets > 0 then
                    for _, item in ipairs(currentTargets) do
                        if config.Trash_AutoFarm and AreTrashMarkersPresent() then break end
                        local target = item.Part
                        if target and target.Parent and target:IsA("BasePart") then
                            local successPos, targetPos = pcall(function() return target.Position end)
                            if successPos and typeof(targetPos) == "Vector3" then
                                tokenAttempts[item.ParentObj] = (tokenAttempts[item.ParentObj] or 0) + 1
                                if tokenAttempts[item.ParentObj] > 10 then
                                    stuckTokens[item.ParentObj] = true
                                    EventLog("Ignored token (stuck/unreachable).")
                                end
                                hrp.Velocity = Vector3.new(0, -10, 0)
                                hrp.Position = targetPos + Vector3.new(0, 2.5, 0)
                                task.wait(config.Token_Cooldown)
                            end
                        end
                    end
                else
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

            -- [ESTADO 5] FUERA DEL MAPA
            task.wait(3)
            if GetLadderPart() or GetBoatTopInstance() or GetDivePart() then
                continue
            end
            if config.Auto_TP_Event then
                EventLog("Event Map not detected. Attempting UI navigation to Event...")
                Tp2Event()
                task.wait(3)
            else
                task.wait(1)
            end
        end
        task.wait(ScanCooldown)
    end
end)
