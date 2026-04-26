--_G.SafeZone = true
_G.TP_Cooldown = 0.05

local SafeZoneCD = 0.1 
local FixedSafePos = Vector3.new(-7.570, 380.103, 86.898)

local player = game.Players.LocalPlayer
local siguiendoABee = false
local enZonaSegura = false

print("------------------------------------------")
print("--- BEE TRACKER [Global SafeZone Toggle] ---")
print("------------------------------------------")

task.spawn(function()
    while true do
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        local gameFolder = workspace:FindFirstChild("Game")
        local playersFolder = gameFolder and gameFolder:FindFirstChild("Players")
        
        if hrp then
            local bee = playersFolder and playersFolder:FindFirstChild("Bee")
            local beeHRP = bee and bee:FindFirstChild("HumanoidRootPart")

            if beeHRP then
                if not siguiendoABee then
                    print("--- BEE found! teleporting..")
                    siguiendoABee = true
                    enZonaSegura = false
                end
                pcall(function()
                    hrp.Position = beeHRP.Position + Vector3.new(0, 2, 0)
                end)
            else
                if _G.BeeSafeZone  then
                    if not enZonaSegura then
                        print("--- BEE not found, returning to Fixed Safe Zone...")
                        enZonaSegura = true
                        siguiendoABee = false
                    end
                    hrp.Position = FixedSafePos
                    hrp.Velocity = Vector3.new(0, 0.2, 0)
                else
                    if siguiendoABee or enZonaSegura then
                        print("--- BEE not found, SafeZone is OFF. Standing still.")
                        siguiendoABee = false
                        enZonaSegura = false
                    end
                end
            end
        end
        task.wait(siguiendoABee and _G.TP_Cooldown or SafeZoneCD)
    end
end)
