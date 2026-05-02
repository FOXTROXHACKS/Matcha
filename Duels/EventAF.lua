_G.Duels_Autofarm = true
_G.Cooldown_Duels = 0.05
local ScanDelay = 0.5
local player = game:GetService("Players").LocalPlayer
local spawnablesFolder = workspace.Spawnables.SpawnablesClient
local esperandospawnables = false
local recolectando = false

UI.AddTab("Duels", function(tab)
    local sec = tab:Section("Duels Settings", "Left")
    sec:Toggle("duels_toggle", "Enable AutoFarm", _G.Duels_Autofarm, function(state)
        _G.Duels_Autofarm = state
        local statusText = state and "On" or "Off"
        notify("Autofarm", "Status: " .. statusText, 2)
    end)
    sec:SliderInt("duels_cooldown", "Collection Delay (ms)", 1, 100, (_G.Cooldown_Duels * 100), function(val)
        _G.Cooldown_Duels = val / 100
    end)
end)
task.spawn(function()
	notify("Autofarm", "Autofarm has loaded succesfuly...", 2)
    while true do
        if not UI.GetValue("duels_toggle") then 
            task.wait(0.5) 
            continue 
        end
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            task.wait(1) 
            continue 
        end
        local spawnables = spawnablesFolder:GetChildren()
        local ProcessedThisRound = 0
        if #spawnables > 0 then
            if not recolectando then
                print("--- Spawnables found, collecting...")
                recolectando = true
                esperandospawnables = false
            end
            for _, spawnbls in ipairs(spawnables) do
                if not UI.GetValue("duels_toggle") then break end

                if spawnbls:IsA("MeshPart") and spawnbls.Parent ~= nil then
                    pcall(function()
                        hrp.Position = spawnbls.Position + Vector3.new(0, 3, 0)
                    end)
                    ProcessedThisRound = ProcessedThisRound + 1
                    task.wait(_G.Cooldown_Duels)
                end
            end
            if ProcessedThisRound > 0 then
                notify("Round finished, processed: " .. ProcessedThisRound,2)
            end
        else
            if not esperandospawnables then
                pcall(function()
                    if notify then
                        notify("Autofarm", "Finished, waiting for spawnables...", 2)
                    end
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
