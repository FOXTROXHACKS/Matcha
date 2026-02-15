--config
--[[
local Collect = 0.3 
local ScanCooldown = 0.5
local SafeZoneCD = 4
]]

local player = game.Players.LocalPlayer
local ticketsFolder = workspace.Game.Effects.Tickets
local safeZonesFolder = workspace.Game.Map.SafeZones -- Carpeta que contiene las piezas
local esperandoTickets = false
local recolectando = false

print("------------------------------------------")
print("--- TICKET FARM")
print("--- Usando Position en SafeZone.SafeZone")
print("------------------------------------------")

task.spawn(function()
    while true do
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        
        if hrp then
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
                            task.wait(Cooldown)
                        end
                    end)
                end
            else
                if not esperandoTickets then
                    print("--- Done collecting, going to safe zone...")
                    esperandoTickets = true
                    recolectando = false
                end

                local dest = safeZonesFolder:FindFirstChild("SafeZone") or safeZonesFolder:FindFirstChildWhichIsA("BasePart")
                
                if dest then
                    pcall(function()
                        hrp.Position = dest.Position + Vector3.new(0, 5, 0)
                    end)
                end
                
                task.wait(SafeZoneCD)
            end
        end
        task.wait(ScanCooldown)
    end
end)
