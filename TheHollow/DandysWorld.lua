local Pumpkin_TP = true
local Door_Farm = true
local Speed = 30
local Door_Cooldown = 2

local TP_Delay = 0.5
local TP_Height = 0
local Door_Height = 0
local E_KEY = 0x45
local DOOR_COLOR = {255, 106, 0}
local Color_Tolerance = 3
local Debug_Doors = true

local LocalPlayer = game:GetService("Players").LocalPlayer
local skipUntil = {}
local seenColor = {}

UI.AddTab("Halloween", function(tab)
    local sec = tab:Section("Dandy's World - Halloween Farm", "Left")
    sec:Text("Settings")
    sec:Toggle("pumpkin_toggle", "Enable Pumpkin Farm", Pumpkin_TP, function(state)
        Pumpkin_TP = state
        notify("Pumpkin Farm", (state and "Enabled" or "Disabled"), 2)
    end)
    sec:Toggle("door_toggle", "Enable Door Farm", Door_Farm, function(state)
        Door_Farm = state
        if state then skipUntil = {} end
        notify("Door Farm", (state and "Enabled" or "Disabled"), 2)
    end)
    sec:SliderInt("farm_speed", "Speed (studs/s)", 10, 200, Speed, function(val)
        Speed = val
    end)
    sec:SliderInt("farm_delay", "Delay on arrival (ds)", 1, 30, math.floor(TP_Delay * 10), function(val)
        TP_Delay = val / 10
    end)
    sec:SliderInt("pumpkin_height", "Pumpkin height offset", 0, 10, TP_Height, function(val)
        TP_Height = val
    end)
end)

local function getPumpkinPart(pumpkin)
    local part = pumpkin:FindFirstChild("Pumpkin_Flat_Normal")
    if part then return part end
    if pumpkin:IsA("BasePart") then return pumpkin end
    return pumpkin:FindFirstChildWhichIsA("BasePart")
end

local function getDoors()
    local list = {}
    local room = workspace:FindFirstChild("CurrentRoom")
    local map = room and room:FindFirstChild("HalloweenMap2")
    local doors = map and map:FindFirstChild("TrickOrTreatDoors")
    if not doors then return list end

    for _, door in ipairs(doors:GetChildren()) do
        local glows = door:FindFirstChild("Glows")
        if glows then
            local part = glows
            if not glows:IsA("BasePart") then
                part = glows:FindFirstChildWhichIsA("BasePart")
            end
            if part then
                table.insert(list, { part = part, id = door.Address, name = door.Name })
            end
        end
    end
    return list
end

local function isUnclaimed(part, id, name)
    local ok, c = pcall(function() return part.Color end)
    if not ok or not c then return false end

    local r, g, b = c.R, c.G, c.B -- Matcha ya devuelve 0-255

    if Debug_Doors and id and not seenColor[id] then
        seenColor[id] = true
        print(string.format("[DOOR] %s | color: %.0f, %.0f, %.0f", name or "?", r, g, b))
    end

    return math.abs(r - DOOR_COLOR[1]) <= Color_Tolerance
       and math.abs(g - DOOR_COLOR[2]) <= Color_Tolerance
       and math.abs(b - DOOR_COLOR[3]) <= Color_Tolerance
end
local function pickTarget(root)
    local best, bestDist = nil, math.huge

    if Pumpkin_TP then
        for _, object in ipairs(workspace:GetChildren()) do
            if object.Name == "TreatPumpkinLocal" then
                local part = getPumpkinPart(object)
                if part then
                    local d = (part.Position - root.Position).Magnitude
                    if d < bestDist then
                        best = { kind = "pumpkin", part = part }
                        bestDist = d
                    end
                end
            end
        end
    end

    if Door_Farm then
        for _, door in ipairs(getDoors()) do
            if (skipUntil[door.id] or 0) <= tick() and isUnclaimed(door.part, door.id, door.name) then
                local d = (door.part.Position - root.Position).Magnitude
                if d < bestDist then
                    best = { kind = "door", part = door.part, id = door.id }
                    bestDist = d
                end
            end
        end
    end

    return best
end

local function targetStillValid(t)
    if not t.part.Parent then return false end
    if t.kind == "pumpkin" then return Pumpkin_TP end
    return Door_Farm and isUnclaimed(t.part)
end

local function tweenToTarget(root, target)
    local last = tick()
    local height = (target.kind == "door") and Door_Height or TP_Height

    while Pumpkin_TP or Door_Farm do
        task.wait(0.03)

        if not targetStillValid(target) then return false end

        local now = tick()
        local dt = now - last
        last = now

        local cur = root.Position
        local tgt = target.part.Position + Vector3.new(0, height, 0)

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
        if not (Pumpkin_TP or Door_Farm) then continue end

        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        local target = pickTarget(root)
        if not target then
            task.wait(0.5)
            continue
        end

        local arrived = tweenToTarget(root, target)

        if arrived then
            if target.kind == "door" and isrbxactive() then
                task.wait(0.2)
                keypress(E_KEY)
                task.wait(0.1)
                keyrelease(E_KEY)
                skipUntil[target.id] = tick() + Door_Cooldown
            end
            task.wait(TP_Delay)
        end
    end
end)

notify("Halloween Farm Loaded", "Dandy's World", 3)
