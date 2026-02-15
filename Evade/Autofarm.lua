--[[V1.1
+ fixed mapchange crashing the script
+ upgraded safe method
]]
--[[
local Collect = 0.3 
local ScanCooldown = 0.5
local SafeZoneCD = 4
]]

local player = game.Players.LocalPlayer
local esperandoTickets = false
local recolectando = false

print("------------------------------------------")
print("--- TICKET FARM")
print("------------------------------------------")

task.spawn(function()
    while true do
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        local gameFolder = workspace:FindFirstChild("Game")
        local effects = gameFolder and gameFolder:FindFirstChild("Effects")
        local ticketsFolder = effects and effects:FindFirstChild("Tickets")
        
        local map = gameFolder and gameFolder:FindFirstChild("Map")
        local safeZonesFolder = map and map:FindFirstChild("SafeZones")

        if hrp and ticketsFolder and safeZonesFolder then
            local allTickets = ticketsFolder:GetChildren()
            local currentTickets = {}

            for _, t in ipairs(allTickets) do
                local mover = t:FindFirstChild("Mover")
                if mover and mover:IsA("BasePart") then
                    table.insert(currentTickets, mover)
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
                    print("--- Collected, going to Safe Zone...")
                    esperandoTickets = true
                    recolectando = false
                end
                    
                local dest = safeZonesFolder:FindFirstChild("SafeZone") or safeZonesFolder:FindFirstChildWhichIsA("BasePart") or safeZonesFolder:FindFirstChildWhichIsA("Part")
                
                if dest then
                    pcall(function()
                        hrp.Position = dest.Position + Vector3.new(0, 5, 0)
                    end)
                end
                
                task.wait(SafeZoneCD)
            end
        else
            if not esperandoTickets then
                print("--- [SYSTEM]: Map not detected, waiting for folders...")
                esperandoTickets = true
            end
            task.wait(1)
        end
        
        task.wait(ScanCooldown)
    end
end)
