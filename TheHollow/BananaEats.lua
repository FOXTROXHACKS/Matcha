local TP_Height = 3     -- height above the key
local Door_Height = 0   -- height above the door
local Key_Delay = 1     -- seconds to wait at the key before going to the door

local LocalPlayer = game:GetService("Players").LocalPlayer

local function getRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local keeper = workspace:FindFirstChild("GameKeeper")

-- Step 1: TP once to the nearest HollowKey
local root = getRoot()
local map = keeper and keeper:FindFirstChild("Map")
local items = map and map:FindFirstChild("Items")

if not root then
    print("[LOG] Character not found")
elseif not items then
    print("[LOG] Items folder not found")
else
    local best, bestDist = nil, math.huge

    for _, key in ipairs(items:GetChildren()) do
        if key.Name == "HollowKey" then
            local spawn = key:FindFirstChild("SpawnRoot")
            if spawn then
                local d = (spawn.Position - root.Position).Magnitude
                if d < bestDist then
                    best, bestDist = spawn, d
                end
            end
        end
    end

    if best then
        root.Position = best.Position + Vector3.new(0, TP_Height, 0)
        print("[LOG] Teleported to HollowKey")
        task.wait(Key_Delay)
    else
        print("[LOG] No HollowKey found, going straight to the door")
    end
end

print("[LOG] Teleporting to EscapeDoor...")

while true do
    task.wait(0.1)

    local r = getRoot()
    local exits = keeper and keeper:FindFirstChild("Exits")
    local door = exits and exits:FindFirstChild("EscapeDoor")
    local doorRoot = door and door:FindFirstChild("NeonBack")

    if r and doorRoot then
        pcall(function()
            r.Position = doorRoot.Position + Vector3.new(0, Door_Height, 0)
        end)
    end
end
