local TP_Height = 3
local Door_Height = 0
local Key_Delay = 1

local LocalPlayer = game:GetService("Players").LocalPlayer
local function getRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local keeper = workspace:FindFirstChild("GameKeeper")
local map = keeper and keeper:FindFirstChild("Map")
local items = map and map:FindFirstChild("Items")
local exits = keeper and keeper:FindFirstChild("Exits")

for i = 1, 3 do
    local Humroot = getRoot()
    if not Humroot then
        print("[LOG] Character not found")
        break
    elseif not items then
        print("[LOG] Items folder not found")
        break
    else
        local best, bestDist = nil, math.huge

        for _, key in ipairs(items:GetChildren()) do
            if key.Name == "HollowKey" then
                local spawn = key:FindFirstChild("SpawnRoot")
                if spawn then
                    local d = (spawn.Position - Humroot.Position).Magnitude
                    if d < bestDist then
                        best, bestDist = spawn, d
                    end
                end
            end
        end

        if best then
            Humroot.Position = best.Position + Vector3.new(0, TP_Height, 0)
            print("[LOG] Teleported to HollowKey (Attempt " .. i .. " of 3)")
            task.wait(Key_Delay)
        else
            print("[LOG] No HollowKey found, skipping...")
            break
        end
    end
end

print("[LOG] Teleporting to EscapeDoor 3 times...")

for i = 1, 3 do
    local r = getRoot()
    local door = exits and exits:FindFirstChild("EscapeDoor")
    local doorRoot = door and door:FindFirstChild("NeonBack")

    if r and doorRoot then
        pcall(function()
            r.Position = doorRoot.Position + Vector3.new(0, Door_Height, 0)
            print("[LOG] Teleported to EscapeDoor (Attempt " .. i .. " of 3)")
        end)
    else
        print("[LOG] EscapeDoor or NeonBack not found")
    end
    task.wait(0.5)
end

print("[LOG] Process complete!")
