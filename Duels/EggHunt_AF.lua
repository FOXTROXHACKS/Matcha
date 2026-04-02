local KeyToggle = Enum.KeyCode.Z
local Cooldown = 0.3 
local ScanDelay = 0.5
local player = game:GetService("Players").LocalPlayer

local eggFolder = workspace.EggHunt
local UserInputService = game:GetService("UserInputService")

local esperandospawnables = false
local recolectando = false
local autofarmActivo = false 

print("------------------------------------------")
print("--- EggHunt AF: Active")
print("--- Press 'Z' to Start/Stop Collecting")
print("------------------------------------------")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == KeyToggle then
        autofarmActivo = not autofarmActivo
        local estado = autofarmActivo and "ENABLED" or "DISABLED"
        
        print("[MATCHA]: Autofarm " .. estado)
        if notify then
            notify("Autofarm", "Status: " .. estado, 2)
        end
    end
end)

task.spawn(function()
    while true do
        if not autofarmActivo then 
            recolectando = false
            task.wait(0.5) 
            continue 
        end
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            task.wait(1) 
            continue 
        end
        local spawnables = {}
        for _, v in ipairs(eggFolder:GetDescendants()) do
            if v:IsA("TouchInterest") and v.Parent:IsA("MeshPart") then
                table.insert(spawnables, v.Parent)
            end
        end

        local ProcessedThisRound = 0
        if #spawnables > 0 then
            if not recolectando then
                print("--- Eggs found, collecting...")
                recolectando = true
                esperandospawnables = false
            end
            for _, spawnbls in ipairs(spawnables) do
                if not autofarmActivo then break end

                if spawnbls:IsA("MeshPart") and spawnbls.Parent ~= nil then
                    pcall(function()
                        hrp.Position = spawnbls.Position
                    end)
                    ProcessedThisRound = ProcessedThisRound + 1
                    task.wait(Cooldown)
                end
            end
            if ProcessedThisRound > 0 then
                print("Round finished, processed: " .. ProcessedThisRound)
            end
        else
            if not esperandospawnables then
                pcall(function()
                    if notify then notify("Autofarm", "Finished, waiting for spawnables...", 2) end
                end)
                print("DONEEEE.")
                esperandospawnables = true
                recolectando = false
            end
            task.wait(ScanDelay)
        end
        
        task.wait(0.1)
    end
end)
