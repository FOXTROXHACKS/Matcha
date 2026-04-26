--[[
[+] EVADE Autofarm v1
[+] Made GUI using matcha UI
[+] Made toggles for autofarm, npc, sfaezone and position logs
]]
_G.Full_AutoFarm = true
_G.SafeZone = true
_G.NPC_AutoFarm = true
_G.TP_Cooldown = 0.05
_G.LOGS = false

UI.AddTab("AutoFarm", function(tab)
    local sec = tab:Section("Configuration", "Left")
    sec:Toggle("full_autofarm", "Tickets AutoFarm", _G.Full_AutoFarm, function(state)
        _G.Full_AutoFarm = state
    end)
    sec:Toggle("npc_toggle", "NPC AutoFarm", _G.NPC_AutoFarm, function(state)
        _G.NPC_AutoFarm = state
    end)
    sec:Toggle("safezone_toggle", "Safe Zone", _G.SafeZone, function(state)
        _G.SafeZone = state
    end)
    sec:SliderInt("tp_cooldown_slider", "TP Cooldown (ms)", 1, 100, 5, function(val)
        _G.TP_Cooldown = val / 100
    end)
    sec:Toggle("logs_toggle", "Position Logs", _G.LOGS, function(state)
        _G.LOGS = state
    end)
end)

local Collect = 0.3 
local ScanCooldown = 0.5
local SafeZoneCD = 0.1 
local TotalTicketsFound = 0

local SafePositions = {
    Vector3.new(-230, 280, -200),
    Vector3.new(0, 280, 0),
    Vector3.new(230, 280, 200)
}

local player = game.Players.LocalPlayer
local esperando = false
local recolectando = false
local lastPosChange = 0
local currentSafePos = SafePositions[1]

print("--- Full AutoFarm LOADED ---")

task.spawn(function()
    while true do
        if not _G.Full_AutoFarm then task.wait(0.5) continue end

        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        
        local gameFolder = workspace:FindFirstChild("Game")
        local effects = gameFolder and gameFolder:FindFirstChild("Effects")
        local ticketsFolder = effects and effects:FindFirstChild("Tickets")
        local playersFolder = gameFolder and gameFolder:FindFirstChild("Players")

        if hrp then
            local currentTickets = {}
            local NPC = _G.NPC_AutoFarm and playersFolder and playersFolder:FindFirstChild("Bee")
            local NPCHRP = NPC and NPC:FindFirstChild("HumanoidRootPart")

            if not NPCHRP and ticketsFolder then
                local allChildren = ticketsFolder:GetChildren()
                for i = 1, #allChildren do
                    local t = allChildren[i]
                    local mover = t:FindFirstChild("Mover")
                    if mover and mover:IsA("BasePart") then
                        table.insert(currentTickets, mover)
                    end
                end
            end

            if NPCHRP then
                recolectando = true
                esperando = false
                hrp.Position = NPCHRP.Position + Vector3.new(0, 2, 0)
                hrp.Velocity = Vector3.new(0, 0, 0)
            elseif #currentTickets > 0 then
                recolectando = true
                esperando = false
                for _, target in ipairs(currentTickets) do
                    local startTime = tick()
                    while tick() - startTime < Collect do
                        if target and target.Parent and hrp then
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            hrp.Position = target.Position + Vector3.new(0, 1.5, 0)
                            TotalTicketsFound = TotalTicketsFound + 1
                            print("--Found Ticket. [Tickets found so far.. "..TotalTicketsFound.."]")
                            task.wait(1)
                        else
                            break
                        end
                        task.wait()
                    end
                end
            else
                if _G.SafeZone then
                    if not esperando then
                        esperando = true
                        recolectando = false
                        currentSafePos = SafePositions[math.random(1, #SafePositions)]
                        print("--- No tickets, returning to Fixed Safe Zone...")
                        if _G.LOGS == true then
                            print("Position: "..tostring(currentSafePos))
                        end
                        lastPosChange = tick()
                    end
                    if tick() - lastPosChange >= 3 then
                        currentSafePos = SafePositions[math.random(1, #SafePositions)]
                        if _G.LOGS == true then
                            print("Position: "..tostring(currentSafePos))
                        end
                        lastPosChange = tick()
                    end
                    hrp.Position = currentSafePos
                    hrp.Velocity = Vector3.new(0, 0, 0)
                else
                    esperando = false
                    recolectando = false
                end
            end
        end
        
        local waitTime = SafeZoneCD
        if recolectando then waitTime = ScanCooldown end

        if _G.NPC_AutoFarm and _G.TP_Cooldown then 
             local isTracking = _G.NPC_AutoFarm and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
             if isTracking then waitTime = _G.TP_Cooldown end
        end
        task.wait(waitTime)
    end
end)
