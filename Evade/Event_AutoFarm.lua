--[[
[+] V 2.2 - HYBRID FARMER (Fix Nil Error)
[+] NPC_AutoFarm Toggle integrado
[+] Corrección de error de longitud en currentTickets
]]
--[[
-- Global Config
_G.SafeZone = true         
_G.NPC_AutoFarm = true      
_G.TP_Cooldown = 0.05
_G.LOGS = false
]]
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
                        if LOGS == true then
                            print("Position: "..tostring(currentSafePos))
                        end
                        lastPosChange = tick()
                    end
                    if tick() - lastPosChange >= 3 then
                        currentSafePos = SafePositions[math.random(1, #SafePositions)]
                        if LOGS == true then
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
