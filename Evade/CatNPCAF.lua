local TP_Cooldown = 0.1

local SafeZoneCD = 0.1 

local FixedSafePos = Vector3.new(-7.570, 380.103, 86.898)

local player = game.Players.LocalPlayer
local siguiendoANPC = false
local enZonaSegura = false

print("------------------------------------------")
print("--- Cat TRACKER ---")
print("------------------------------------------")

task.spawn(function()
    while true do
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        local gameFolder = workspace:FindFirstChild("Game")
        local playersFolder = gameFolder and gameFolder:FindFirstChild("Players")
        
        if hrp then
            local NPC = playersFolder and playersFolder:FindFirstChild("Glorp Cat")-- or playersFolder:FindFirstChild("Glorp Cat")
            local NPC_HRP = NPC and NPC:FindFirstChild("HumanoidRootPart")
            if NPC_HRP then
                if not siguiendoANPC then
                    print("--- NPC found! teleporting..")
                    siguiendoANPC = true
                    enZonaSegura = false
                end
                pcall(function()
                    hrp.Position = NPC_HRP.Position + Vector3.new(0, 2, 0)
                end)
            else
                if not enZonaSegura then
                    print("--- NPC not found, returning to Fixed Safe Zone...")
                    enZonaSegura = true
                    siguiendoANPC = false
                end
                hrp.Position = FixedSafePos
                hrp.Velocity = Vector3.new(0, 0.2, 0)
            end
        end
        task.wait(siguiendoANPC and TP_Cooldown or SafeZoneCD)
    end
end)
