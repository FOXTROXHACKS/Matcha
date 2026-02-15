--[[V1.2
+ fixed mapchange crashing the script
+ upgraded safe method
]]
--[[
local Collect = 0.3 
local ScanCooldown = 0.5
local SafeZoneCD = 0.1 -- Bajamos esto para que el "anclaje" sea constante
]]
-- CONFIGURACIÓN


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
        local map = gameFolder and gameFolder:FindFirstChild("Map")
        local effects = gameFolder and gameFolder:FindFirstChild("Effects")
        local ticketsFolder = effects and effects:FindFirstChild("Tickets")
        
        local safeZonesFolder = map and map:FindFirstChild("SafeZones")
        local invisPartsFolder = map and map:FindFirstChild("InvisParts")

        if hrp and ticketsFolder then
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
                    print("--- Going to Safe Zone (Static Mode)...")
                    esperandoTickets = true
                    recolectando = false
                end

                local dest = safeZonesFolder and (safeZonesFolder:FindFirstChild("SafeZone") or safeZonesFolder:FindFirstChild("Part") or safeZonesFolder:FindFirstChildWhichIsA("BasePart"))
                
                if not dest and invisPartsFolder then
                    dest = invisPartsFolder:FindFirstChild("Part")
                end
                
                if dest then
                    hrp.Position = dest.Position + Vector3.new(0, 5, 0)
                    hrp.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end
        task.wait(SafeZoneCD)
    end
end)
