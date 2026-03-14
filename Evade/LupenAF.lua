local FixedSafePos = Vector3.new(-7.570, 380.103, 86.898)
local TP_Cooldown = 0.1 -- Velocidad de seguimiento a Lupen
local SafeZoneCD = 0.1 

local player = game.Players.LocalPlayer
local siguiendoALupen = false
local enZonaSegura = false

print("------------------------------------------")
print("--- LUPEN TRACKER ---")
print("------------------------------------------")

task.spawn(function()
    while true do
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        local gameFolder = workspace:FindFirstChild("Game")
        local playersFolder = gameFolder and gameFolder:FindFirstChild("Players")
        
        if hrp then
            -- Intentamos encontrar a Lupen
            local lupen = playersFolder and playersFolder:FindFirstChild("Lupen")
            local lupenHRP = lupen and lupen:FindFirstChild("HumanoidRootPart")

            if lupenHRP then                if not siguiendoALupen then
                    print("--- Lupen found! teleporting..")
                    siguiendoALupen = true
                    enZonaSegura = false
                end

                pcall(function()
                    -- Mantenemos el estilo de TP de tu script original (+2 en Y)
                    hrp.Position = lupenHRP.Position + Vector3.new(0, 2, 0)
                end)
            else
                if not enZonaSegura then
                    print("--- Lupen not found, returning to Fixed Safe Zone...")
                    enZonaSegura = true
                    siguiendoALupen = false
                end

                hrp.Position = FixedSafePos
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
        end
        task.wait(siguiendoALupen and TP_Cooldown or SafeZoneCD)
    end
end)
