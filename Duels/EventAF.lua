_G.Duels_Autofarm = false
_G.Auto_TP_Pad = false
_G.Cooldown_Duels = 0.3

local PadPath = workspace.PadZones.PadZone5.Pad1.Pad
local player = game:GetService("Players").LocalPlayer
local spawnablesFolder = workspace.Spawnables.SpawnablesClient

UI.AddTab("Duels", function(tab)
    local sec = tab:Section("Main Settings", "Left")
    sec:Toggle("duels_toggle", "Enable AutoFarm", _G.Duels_Autofarm, function(state)
        _G.Duels_Autofarm = state
        notify("Autofarm", (state and "Enabled" or "Disabled"), 2)
    end)
    sec:Toggle("pad_toggle", "Return to Pad", _G.Auto_TP_Pad, function(state)
        _G.Auto_TP_Pad = state
    end)
    sec:SliderInt("duels_cooldown", "Collection Delay (ms)", 1, 100, (_G.Cooldown_Duels * 100), function(val)
        _G.Cooldown_Duels = val / 100
    end)

    local info = tab:Section("Logic Info", "Right")
    info:Text("1. Recolecta todo el mapa.")
    info:Text("2. Si no hay nada, vuelve al Pad.")
    info:Text("3. Espera ahí hasta nueva ronda.")
end)

local yaEnElPad = false

task.spawn(function()
    while true do
        if not UI.GetValue("duels_toggle") then 
            task.wait(0.5) 
            continue 
        end
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local items = spawnablesFolder:GetChildren()
            if #items > 0 then
                yaEnElPad = false
                for _, item in ipairs(items) do
                    if not UI.GetValue("duels_toggle") then break end
                    if item:IsA("MeshPart") and item.Parent ~= nil then
                        pcall(function()
                            hrp.CFrame = item.CFrame + Vector3.new(0, 3, 0)
                        end)
                        task.wait(_G.Cooldown_Duels)
                    end
                end
            else
                if UI.GetValue("pad_toggle") and not yaEnElPad and PadPath then
                    pcall(function()
                        hrp.CFrame = PadPath.CFrame + Vector3.new(0, 3, 0)
                    end)
                    yaEnElPad = true
                    notify("Autofarm", "Mapa limpio. Esperando en Pad...", 2)
                    print("[MATCHA]: Resting on Pad.")
                end
                task.wait(0.5)
            end
        end
        task.wait(0.1)
    end
end)
