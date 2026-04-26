local TP_Cooldown = 0.1
local SafeZoneCD = 0.1 

local FixedSafePos = Vector3.new(-7.570, 380.103, 86.898)

local player = game.Players.LocalPlayer
local siguiendoNPC = false
local enZonaSegura = false


print("------------------------------------------")
print("--- BEE TRACKER ---")
print("------------------------------------------")

task.spawn(function()
    while true do
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
      
        local gameFolder = workspace:FindFirstChild("Game")
        local playersFolder = gameFolder and gameFolder:FindFirstChild("Players")
        
        if hrp then
            local NPC = playersFolder and playersFolder:FindFirstChild("Bee")
            local NPCHRP = NPC and NPC:FindFirstChild("HumanoidRootPart")

            if NPCHRP then
                if not siguiendoNPC then
                    print("--- BEE found! teleporting..")
                    siguiendoNPC = true
                    enZonaSegura = false
                end
                pcall(function()
                    hrp.Position = beeHRP.Position + Vector3.new(0, 2, 0)
                end)
            else
                if _G.SafeZone == true then
                    if not enZonaSegura then
                        print("--- BEE not found, returning to Fixed Safe Zone...")
                        enZonaSegura = true
                        siguiendoNPC = false
                    end
                    hrp.Position = FixedSafePos
                    hrp.Velocity = Vector3.new(0, 0.2, 0)
                    end
            end
        end
        task.wait(siguiendoNPC and TP_Cooldown or SafeZoneCD)
    end
end)
