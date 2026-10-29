local TP_Delay = 0.2

local MODES = {
    { name = "Candy",           folder = "LootSpawns",           keyword = "candy" },
    { name = "Red Balloon",     folder = "HalloweenDecorations", keyword = "redballoon" },
    { name = "Direwick Ticket", folder = "LootSpawns",           keyword = "direwick_ticket", once = true },
}
local mode = 1
local wasEnabled = true
local visited = {}

local LocalPlayer = game:GetService("Players").LocalPlayer

local names = {}
for i, m in ipairs(MODES) do names[i] = m.name end

UI.AddTab("Collector", function(tab)
    local sec = tab:Section("Collector", "Left")
    sec:Text("Settings")
    sec:Toggle("collect_enabled", "Enable Collector", true)
    sec:Combo("collect_mode", "Collect", names, 0)
end)

local function isPart(d)
    if d:IsA("BasePart") then return true end
    local c = d.ClassName
    return c == "MeshPart" or c == "Part" or c == "UnionOperation"
end

local function partOf(obj)
    if isPart(obj) then return obj end
    local head = obj:FindFirstChild("Head")
    if head and isPart(head) then return head end
    for _, d in ipairs(obj:GetDescendants()) do
        if isPart(d) then return d end
    end
    return nil
end
local function collect(cfg)
    local list, seen = {}, {}
    for _, map in ipairs(workspace:GetChildren()) do
        local folder = map:FindFirstChild(cfg.folder)
        if folder then
            for _, d in ipairs(folder:GetDescendants()) do
                local n = (d.Name:lower():gsub("%s+", ""))
                if n:find(cfg.keyword, 1, true) then
                    local part = partOf(d)
                    if part and not seen[part.Address] then
                        seen[part.Address] = true
                        table.insert(list, part)
                    end
                end
            end
        end
    end
    return list
end

print("[LOG] Collector loaded")

while true do
    task.wait(0.1)
    local okE, en = pcall(UI.GetValue, "collect_enabled")
    local enabled = (not okE) or en == nil or en == true
    if enabled ~= wasEnabled then
        wasEnabled = enabled
        visited = {}
        notify("Collector", (enabled and "Enabled" or "Disabled"), 2)
    end
    if not enabled then continue end
    local okV, idx = pcall(UI.GetValue, "collect_mode")
    local newMode = (okV and type(idx) == "number" and MODES[idx + 1]) and (idx + 1) or 1
    if newMode ~= mode then
        mode = newMode
        visited = {}
        notify("Collecting: " .. MODES[mode].name, "Collector", 2)
    end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then continue end

    local cfg = MODES[mode]
    local items = collect(cfg)

    -- Modo "una vez": no vuelve a ir al mismo objeto hasta que desaparezca y reaparezca
    if cfg.once then
        local present = {}
        for _, p in ipairs(items) do present[p.Address] = true end
        for addr in pairs(visited) do
            if not present[addr] then visited[addr] = nil end
        end
    end

    local best, bestDist = nil, math.huge
    for _, p in ipairs(items) do
        if not visited[p.Address] then
            local d = (p.Position - root.Position).Magnitude
            if d < bestDist then
                best, bestDist = p, d
            end
        end
    end

    if best then
        pcall(function() root.Position = best.Position end)
        visited[best.Address] = true
        task.wait(TP_Delay)
    else
        if #items == 0 then
            print("[LOG] No " .. cfg.name .. " found")
            task.wait(2)
        elseif cfg.once then
            task.wait(1)
        else
            visited = {}
            task.wait(1)
        end
    end
end
