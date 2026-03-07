-- CONFIGURACIÓN GENERAL
local Cooldown = 0.3 
local ScanDelay = 0.5
local KeyTP = Enum.KeyCode.Z
local PadPath = workspace.PadZones.PadZone5.Pad1.Pad

local player = game:GetService("Players").LocalPlayer
local spawnablesFolder = workspace.Spawnables.SpawnablesClient
local UserInputService = game:GetService("UserInputService")

-- FLAGS DE ESTADO
local esperandoHearts = false
local recolectando = false

print("------------------------------------------")
print("--- Duels AF & Pad TP: Active")
print("--- Press 'Z' to teleport to PadZone5")
print("------------------------------------------")

--- 1. LÓGICA DEL TELEPORT (KEYBIND Z) ---
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == KeyTP then
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        
        if hrp and PadPath then
            print("[MATCHA]: Teleporting to Pad...")
			notify("Autofarm", "Teleported to Plate.", 2)
            pcall(function()
                hrp.Position = PadPath.Position + Vector3.new(0, 3, 0)
            end)
        else
            print("[MATCHA]: Error - Pad not found or Character missing.")
        end
    end
end)

--- 2. LÓGICA DEL AUTOFARM INFINITO ---
task.spawn(function()
    while true do
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        
        if not hrp then 
            task.wait(1) 
            continue 
        end

        local spawnables = spawnablesFolder:GetChildren()
        local ProcessedThisRound = 0

        if #spawnables > 0 then
            -- Aviso de inicio de recolección
            if not recolectando then
                print("--- Hearts spawned, collecting...")
                recolectando = true
                esperandoHearts = false
            end

            for _, spawnbls in ipairs(spawnables) do
                if spawnbls:IsA("MeshPart") and spawnbls.Parent ~= nil then
                    pcall(function()
                        hrp.Position = spawnbls.Position + Vector3.new(0, 3, 0)
                    end)
                    ProcessedThisRound = ProcessedThisRound + 1
                    task.wait(Cooldown)
                end
            end
            
            if ProcessedThisRound > 0 then
                print("Round finished, processed: " .. ProcessedThisRound)
            end
            
        else
            if not esperandoHearts then
                pcall(function()
                    notify("Autofarm", "Finished, waiting for hearts...", 2)
                end)
                print("DONEEEE.")
                esperandoHearts = true
                recolectando = false
            end
            task.wait(ScanDelay)
        end
        
        task.wait(0.1)
    end
end)
