DuelsAutoFarm = true
task.wait(2)


    print("[LOG] Script Loaded")
    local Duels_Autofarm = true
    local Auto_Queue = true
    local Keybind_Use = true 
    local Cooldown_Duels = 0.05
    local clickCD = 0.5
    local lastSeenTime = tick()
    local PadWaitTime = 3
    --local PadPath = workspace.PadZones.PadZone5.Pad1.Pad
    local player = game:GetService("Players").LocalPlayer
    local spawnablesFolder = workspace.Spawnables.SpawnablesClient
    local lastPadTP = 0
    
    -- UI Setup
    UI.AddTab("Duels", function(tab)
        local sec = tab:Section("Duels Autofarm - V1.5", "Left")
        sec:Text("Settings")
        sec:Toggle("duels_toggle", "Enable AutoFarm", Duels_Autofarm, function(state)
            Duels_Autofarm = state
            notify("Autofarm", (state and "Enabled" or "Disabled"), 2)
        end)
        sec:Toggle("auto_queue", "Auto Queue", Auto_Queue, function(state)
            Auto_Queue = state
            notify("Pad TP", (state and "Active" or "Inactive"), 2)
        end)
        sec:Toggle("keybind_toggle", "Enable Keybind Use (Insert)", Keybind_Use, function(state)
            Keybind_Use = state
            if not state and iskeypressed(0x2D) then
                keyrelease(0x2D)
            end
        end)
        sec:SliderInt("duels_cooldown", "Collection Delay (ms)", 1, 100, (Cooldown_Duels * 100), function(val)
            Cooldown_Duels = val / 100
        end)
    end)
    --functions
    local function SimClick(posx, posy)
        if mousemoveabs and mouse1click then
            mousemoveabs(posx, posy)
            task.wait(0.5)
            mousemoveabs(posx + 1, posy)
            task.wait(0.5)
            mouse1click()
            print("[LOG] Click ejecutado en: " .. posx .. ", " .. posy)
        else
            warn("Las funciones de mouse no están disponibles en este entorno.")
        end
    end
    -- Main Loop
    task.spawn(function()
        while true do
            task.wait(0.1)
            if not Duels_Autofarm then continue end
            
            local character = player.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
    
            -- 1. Escaneo
            local foundItems = {}
            for _, folder in ipairs(spawnablesFolder:GetChildren()) do
                local cylinder = folder:FindFirstChild("Cylinder")
                if cylinder and cylinder:IsA("BasePart") then
                    table.insert(foundItems, cylinder)
                end
            end
    
            local count = #foundItems
            local isToggled = Keybind_Use
    
            -- 2. Lógica de Activación (Presionar antes de farmear)
            if count > 0 then
                lastSeenTime = tick()
                if isToggled and not iskeypressed(0x2D) then
                    keypress(0x2D)
                    task.wait(0.5) -- Espera breve para que el juego registre la tecla antes de mover
                end
                
                -- 3. Proceder con el Farmeo
                for _, item in ipairs(foundItems) do
                    if not Duels_Autofarm then break end
                    if item.Parent then
                        pcall(function() hrp.CFrame = item.CFrame + Vector3.new(0, 3, 0) end)
                        task.wait(Cooldown_Duels)
                    end
                end
                lastPadTP = tick()
            else
                -- 4. Lógica de Liberación (Solo si no hay monedas)
                if isToggled and iskeypressed(0x2D) then
                    if (tick() - lastSeenTime) >= 2 then
                        keyrelease(0x2D)
                    end
                end
    
                -- Lógica Pad
                if Auto_Queue then -- Usamos este toggle para activar/desactivar la secuencia
                    if (tick() - lastPadTP) >= PadWaitTime then
                        print("[LOG] Iniciando secuencia de clicks...")
                        task.wait(clickCD)
                        SimClick(1652, 473)
            			task.wait(clickCD)
            			SimClick(1157, 837)
                        task.wait(clickCD)
                        SimClick(1016, 1474)
                        lastPadTP = tick()
                    end
                end
            end
        end
    end)
