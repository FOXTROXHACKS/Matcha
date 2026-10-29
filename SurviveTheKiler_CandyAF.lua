local Candy_TP = true         -- habilitado por defecto
local TP_Delay = 0.2           -- segundos de espera en cada candy
local TP_Height = 3           -- altura sobre el candy
local Rescan_Delay = 5        -- segundos entre búsquedas cuando no hay candy
local NO_CANDY_COOLDOWN = 120 -- segundos entre avisos de "no hay candy"
local KEYWORD = "candy"
local SPAWNS_FOLDER_NAME = "LootSpawns"
local MAX_DEPTH = 3           -- hasta qué nivel dentro de workspace buscar la carpeta
local SEARCH_WHOLE_WORKSPACE = false -- true = si no existe la carpeta, busca "candy" en todo workspace (más pesado)
local E_KEY = 0x45

local LocalPlayer = game:GetService("Players").LocalPlayer
local visited = {}
local lastNotify = 0
local lastScan = 0
local spawnFolders = {}

UI.AddTab("Candy", function(tab)
    local sec = tab:Section("Candy Collector", "Left")
    sec:Text("Settings")
    sec:Toggle("candy_toggle", "Enable Candy TP", Candy_TP, function(state)
        Candy_TP = state
        if state then visited = {} end
        notify("Candy TP", (state and "Enabled" or "Disabled"), 2)
    end)
    sec:SliderInt("candy_delay", "Delay at each candy (ds)", 1, 50, math.floor(TP_Delay * 10), function(val)
        TP_Delay = val / 10
    end)
    sec:SliderInt("candy_height", "Height offset", 0, 10, TP_Height, function(val)
        TP_Height = val
    end)
end)

local function getRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getPos(obj)
    local ok, pos = pcall(function() return obj.Position end)
    if ok and pos then return pos end
    return nil
end

-- Busca todas las carpetas "LootSpawns", sin importar en qué mapa estén
local function findSpawnFolders()
    local found = {}

    local function scan(parent, depth)
        local ok, children = pcall(function() return parent:GetChildren() end)
        if not ok or not children then return end
        for _, child in ipairs(children) do
            if child.Name == SPAWNS_FOLDER_NAME then
                table.insert(found, child)
            elseif depth < MAX_DEPTH then
                scan(child, depth + 1)
            end
        end
    end

    scan(workspace, 1)
    return found
end

local function scanFolders()
    spawnFolders = findSpawnFolders()
    lastScan = tick()
    visited = {}

    if #spawnFolders > 0 then
        local names = {}
        for _, f in ipairs(spawnFolders) do
            local p = f.Parent
            names[#names + 1] = p and p.Name or "?"
        end
        print("[LOG] " .. SPAWNS_FOLDER_NAME .. " found in: " .. table.concat(names, ", "))
    else
        print("[LOG] " .. SPAWNS_FOLDER_NAME .. " not found")
    end
end

local function collectFrom(container, list)
    local ok, descendants = pcall(function() return container:GetDescendants() end)
    if not ok or not descendants then return end
    for _, d in ipairs(descendants) do
        if d.Name:lower():find(KEYWORD, 1, true) and getPos(d) then
            table.insert(list, d)
        end
    end
end

local function getCandies()
    local list = {}
    for _, folder in ipairs(spawnFolders) do
        collectFrom(folder, list)
    end
    -- Si no hay carpeta y está activado, busca en todo el workspace
    if #spawnFolders == 0 and SEARCH_WHOLE_WORKSPACE then
        collectFrom(workspace, list)
    end
    return list
end

print("[LOG] Candy TP loaded")
scanFolders()

while true do
    task.wait(0.1)
    if not Candy_TP then continue end

    local root = getRoot()
    if not root or not isrbxactive() then continue end

    local candies = getCandies()

    -- Sin candy: puede que el mapa haya cambiado, así que vuelve a buscar la carpeta
    if #candies == 0 and (tick() - lastScan) >= Rescan_Delay then
        scanFolders()
        candies = getCandies()
    end

    local best, bestDist = nil, math.huge
    for _, c in ipairs(candies) do
        if not visited[c.Address] then
            local d = (c.Position - root.Position).Magnitude
            if d < bestDist then
                best, bestDist = c, d
            end
        end
    end

    if best then
        pcall(function()
            root.Position = best.Position + Vector3.new(0, TP_Height, 0)
        end)
        task.wait(0.2)
  
        visited[best.Address] = true
        task.wait(TP_Delay)
    else
        if #candies > 0 then
            print("[LOG] Round complete (" .. #candies .. " candy). Restarting...")
            visited = {}
        else
            if (tick() - lastNotify) >= NO_CANDY_COOLDOWN then
                lastNotify = tick()
                notify("There's no candy at this moment", "Candy TP", 4)
            end
        end
        task.wait(Rescan_Delay)
    end
end
