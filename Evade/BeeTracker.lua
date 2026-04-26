--_G.NPC_SafeZone = true
_G.TP_Cooldown = 0.05
spawn(function()
    while true do
        notify("IMPORTANT", "There is a GUI for this script. check it out in matcha scripts",10)
        task.wait(30)
    end
end)
local SafeZoneCD = 0.1 
local FixedSafePos = Vector3.new(-7.570, 380.103, 86.898)

local player = game.Players.LocalPlayer
local SiguiendoNPC = false
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
            local NPC = playersFolder and playersFolder:FindFirstChild("Bee")
            local NPCHRP = NPC and NPC:FindFirstChild("HumanoidRootPart")

            if NPCHRP then
                if not SiguiendoNPC then
                    print("--- BEE found! teleporting..")
                    SiguiendoNPC = true
                    enZonaSegura = false
                end
                pcall(function()
                    hrp.Position = NPCHRP.Position + Vector3.new(0, 2, 0)
                end)
            else
                if _G.NPC_SafeZone  then
                    if not enZonaSegura then
                        print("--- BEE not found, returning to Fixed Safe Zone...")
                        enZonaSegura = true
                        SiguiendoNPC = false
                    end
                    hrp.Position = FixedSafePos
                    hrp.Velocity = Vector3.new(0, 0.2, 0)
                else
                    if SiguiendoNPC or enZonaSegura then
                        print("--- BEE not found, SafeZone is OFF. Standing still.")
                        SiguiendoNPC = false
                        enZonaSegura = false
                    end
                end
            end
        end
        task.wait(SiguiendoNPC and _G.TP_Cooldown or SafeZoneCD)
    end
end)
