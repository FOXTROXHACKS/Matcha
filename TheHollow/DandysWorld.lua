local Pumpkin_TP = true
local Speed = 30
local TP_Delay = 0.5
local TP_Height = 0

local LocalPlayer = game:GetService("Players").LocalPlayer

UI.AddTab("Pumpkins", function(tab)
    local sec = tab:Section("Dandy's World - Pumpkin Tween", "Left")
    sec:Text("Settings")
    sec:Toggle("pumpkin_tp_toggle", "Enable Pumpkin Tween", Pumpkin_TP, function(state)
        Pumpkin_TP = state
        notify("Pumpkin Tween", (state and "Enabled" or "Disabled"), 2)
    end)
    sec:SliderInt("pumpkin_speed", "Speed (studs/s)", 10, 200, Speed, function(val)
        Speed = val
    end)
    sec:SliderInt("pumpkin_delay", "Delay on arrival (ds)", 1, 30, math.floor(TP_Delay * 10), function(val)
        TP_Delay = val / 10
    end)
    sec:SliderInt("pumpkin_height", "Height offset", 0, 10, TP_Height, function(val)
        TP_Height = val
    end)
end)

local function getPumpkinPart(pumpkin)
    local part = pumpkin:FindFirstChild("Pumpkin_Flat_Normal")
    if part then return part end

    if pumpkin:IsA("BasePart") then
        return pumpkin
    end
    return pumpkin:FindFirstChildWhichIsA("BasePart")
end

local function getNearestPumpkin(root)
    local nearestPart, nearestDist = nil, math.huge

    for _, object in ipairs(workspace:GetChildren()) do
        if object.Name == "TreatPumpkinLocal" then
            local part = getPumpkinPart(object)
            if part then
                local dist = (part.Position - root.Position).Magnitude
                if dist < nearestDist then
                    nearestPart, nearestDist = part, dist
                end
            end
        end
    end

    return nearestPart
end

local function tweenToPart(root, part)
    local last = tick()

    while Pumpkin_TP do
        task.wait(0.03)

        if not part.Parent then return false end

        local now = tick()
        local dt = now - last
        last = now

        local cur = root.Position
        local tgt = part.Position + Vector3.new(0, TP_Height, 0)

        local dx, dy, dz = tgt.X - cur.X, tgt.Y - cur.Y, tgt.Z - cur.Z
        local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
        local step = Speed * dt

        if dist <= step or dist < 0.5 then
            pcall(function() root.Position = tgt end)
            return true
        end

        local k = step / dist
        pcall(function()
            root.Position = Vector3.new(cur.X + dx * k, cur.Y + dy * k, cur.Z + dz * k)
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end)
    end

    return false
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if not Pumpkin_TP then continue end

        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        local part = getNearestPumpkin(root)
        if part then
            local arrived = tweenToPart(root, part)
            if arrived then
                task.wait(TP_Delay)
            end
        else
            task.wait(0.5)
        end
    end
end)

notify("Pumpkin Tween Loaded", "Dandy's World", 3)
