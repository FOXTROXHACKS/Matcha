--[[
[+] V 1.5
[+] Fixed getting killed by nextbots (Hopefully)
[+] Changes SafeZone Positions every 3 secs.
[+] Added a ticket counter (IT ONLY COUNTS HOW MANY TICKETS WERE FOUND, NOT THE TOTAL AMOUNT YOU GAIN)
]]
--_G.SafeZone = true -- Toggle Global
spawn(function()
    while true do
        notify("IMPORTANT", "There is a GUI for this script. check it out in matcha scripts",10)
        task.wait(30)
    end
end)

local Collect = 0.3 
local ScanCooldown = 0.5
local SafeZoneCD = 0.1 
local LOGS = false
local TotalTicketsFound = 0

local SafePositions = {
    Vector3.new(-230, 280, -200),
    Vector3.new(0, 280, 0),
    Vector3.new(230, 280, 200)
}

local player = game.Players.LocalPlayer
local esperandoTickets = false
local recolectando = false
local lastPosChange = 0
local currentSafePos = SafePositions[1]

print("------------------------------------------")
print("--- TICKET FARM - V1.5 [Upgraded safe zone AGAIN]")
print("------------------------------------------")

task.spawn(function()
    while true do
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        local gameFolder = workspace:FindFirstChild("Game")
        local effects = gameFolder and gameFolder:FindFirstChild("Effects")
        local ticketsFolder = effects and effects:FindFirstChild("Tickets")

        if hrp then
            local currentTickets = {}

            if ticketsFolder then
                for _, t in ipairs(ticketsFolder:GetChildren()) do
                    local mover = t:FindFirstChild("Mover")
                    if mover and mover:IsA("BasePart") then
                        table.insert(currentTickets, mover)
                    end
                end
            end

            if #currentTickets > 0 then
                if not recolectando then
                    recolectando = true
                    esperandoTickets = false
                end
                for _, target in ipairs(currentTickets) do
                    local startTime = tick()
                    while tick() - startTime < Collect do
                        if target and target.Parent then
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
                    if not esperandoTickets then
                        esperandoTickets = true
                        print("Waiting for tickets..")
                        recolectando = false
                        currentSafePos = SafePositions[math.random(1, #SafePositions)]
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
                    esperandoTickets = false
                    recolectando = false
                end
            end
        end
        task.wait(recolectando and ScanCooldown or SafeZoneCD)
    end
end)

--[[V1.4
+ Removed SafeZone search by ingame part
+ Changed safezone to now just teleport you up the map
+ Fixed Mapchange crashing logic

local Collect = 0.3 
local ScanCooldown = 0.5
local SafeZoneCD = 0.1 -- Mantiene el personaje anclado en la posición fija

local FixedSafePos = Vector3.new(-7.570, 380.103, 86.898)

local player = game.Players.LocalPlayer
local esperandoTickets = false
local recolectando = false

print("------------------------------------------")
print("--- TICKET FARM - V1.4 [Upgraded safe zone]")
print("------------------------------------------")

task.spawn(function()
    while true do
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        local gameFolder = workspace:FindFirstChild("Game")
        local effects = gameFolder and gameFolder:FindFirstChild("Effects")
        local ticketsFolder = effects and effects:FindFirstChild("Tickets")

        if hrp then
            local currentTickets = {}

            if ticketsFolder then
                local allTickets = ticketsFolder:GetChildren()
                for _, t in ipairs(allTickets) do
                    local mover = t:FindFirstChild("Mover")
                    if mover and mover:IsA("BasePart") then
                        table.insert(currentTickets, mover)
                    end
                end
            end
            if #currentTickets > 0 then
                if not recolectando then
                    print("--- Tickets found!")
                    recolectando = true
                    esperandoTickets = false
                end
                for _, target in ipairs(currentTickets) do
                    pcall(function()
                        if target and target.Parent then
                            hrp.Position = target.Position + Vector3.new(0, 2, 0)
                            task.wait(Collect)
                        end
                    end)
                end
            else
                if not esperandoTickets then
                    print("--- No tickets, returning to Fixed Safe Zone...")
                    esperandoTickets = true
                    recolectando = false
                end

                hrp.Position = FixedSafePos
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
        end
        task.wait(recolectando and ScanCooldown or SafeZoneCD)
    end
end)
]]
