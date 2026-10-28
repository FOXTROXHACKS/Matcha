local ONLY_NAME = nil            -- ej: "LocalPlayerClone". nil = todo lo que tenga HumanoidRootPart
local SKIP_REAL_PLAYERS = false  -- true = ignora los personajes de jugadores reales
local OUTPUT_FILE = "avatar_import.lua"
local LOCAL_CLONE_NAMES = { LocalPlayerClone = true } -- estos nombres usan TU UserId
local USER_IDS = {}              -- opcional: ["NombreDelAvatar"] = 123456789

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local BAD = "failed to fetch text"

local SCALE_MAP = {
    BodyTypeScale = "BodyTypeScale", BodyProportionScale = "ProportionScale",
    BodyWidthScale = "WidthScale", BodyHeightScale = "HeightScale",
    BodyDepthScale = "DepthScale", HeadScale = "HeadScale",
}
local COLOR_MAP = {
    HeadColor3 = "HeadColor", TorsoColor3 = "TorsoColor",
    LeftArmColor3 = "LeftArmColor", RightArmColor3 = "RightArmColor",
    LeftLegColor3 = "LeftLegColor", RightLegColor3 = "RightLegColor",
}
local HD_ID_PROPS = {
    "Shirt", "Pants", "GraphicTShirt", "Face", "Head", "Torso",
    "LeftArm", "RightArm", "LeftLeg", "RightLeg",
}

-- ===== Helpers =====
local function read(obj, prop)
    local ok, v = pcall(function() return obj[prop] end)
    if not ok or v == nil or v == BAD or v == "" then return nil end
    return v
end

local function idOf(v)
    if v == nil then return nil end
    local n = tonumber(v)
    if not n then
        local m = tostring(v):match("(%d+)$")
        n = m and tonumber(m)
    end
    if n and n > 0 then return string.format("%.0f", n) end
    return nil
end

-- Devuelve un número (Enum.Value) o un string (nombre del item) para resolver en Studio
local function enumVal(v)
    if v == nil then return nil end
    if type(v) == "number" then return v end
    local n = read(v, "Value")
    if type(n) == "number" then return n end
    local name = tostring(v):match("^Enum%.%w+%.(%w+)$")
    return name
end

local function rgbOf(c)
    if c == nil then return nil end
    local r, g, b = read(c, "R"), read(c, "G"), read(c, "B")
    if type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" then return nil end
    if math.max(r, g, b) <= 1 and (r % 1 ~= 0 or g % 1 ~= 0 or b % 1 ~= 0) then
        r, g, b = r * 255, g * 255, b * 255
    end
    return { math.floor(r + 0.5), math.floor(g + 0.5), math.floor(b + 0.5) }
end

local function q(s)
    s = tostring(s):gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n"):gsub("\r", "")
    return '"' .. s .. '"'
end

local function lit(v)
    if type(v) == "string" then return q(v) end
    return tostring(v)
end

local function findUserId(model)
    if USER_IDS[model.Name] then return idOf(USER_IDS[model.Name]) end
    if LOCAL_CLONE_NAMES[model.Name] and LocalPlayer then
        return idOf(read(LocalPlayer, "UserId"))
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name == model.Name then return idOf(read(p, "UserId")) end
    end
    return nil
end

-- ===== Leer un avatar =====
local function collect(model)
    local a = {
        name = model.Name,
        rig = model:FindFirstChild("UpperTorso") and "R15" or "R6",
        userId = findUserId(model),
        accessories = {}, bodyParts = {}, colors = {}, scales = {}, hdProps = {},
    }

    for _, d in ipairs(model:GetDescendants()) do
        local cls = d.ClassName

        if cls == "AccessoryDescription" then
            local id = idOf(read(d, "AssetId"))
            if id then
                table.insert(a.accessories, {
                    id = id,
                    type = enumVal(read(d, "AccessoryType")),
                    layered = read(d, "IsLayered"),
                    order = read(d, "Order"),
                    puff = read(d, "Puffiness"),
                })
            end

        elseif cls == "BodyPartDescription" then
            local id = idOf(read(d, "AssetId"))
            local part = enumVal(read(d, "BodyPart"))
            if id and part ~= nil then
                table.insert(a.bodyParts, { id = id, part = part })
            end

        elseif cls == "BodyColors" then
            for src, dst in pairs(COLOR_MAP) do
                local c = rgbOf(read(d, src))
                if c then a.colors[dst] = c end
            end

        elseif cls == "NumberValue" and SCALE_MAP[d.Name] then
            local v = read(d, "Value")
            if type(v) == "number" then a.scales[SCALE_MAP[d.Name]] = v end

        elseif cls == "HumanoidDescription" then
            for _, p in ipairs(HD_ID_PROPS) do
                local id = idOf(read(d, p))
                if id then a.hdProps[p] = id end
            end
        end
    end

    return a
end

-- ===== Buscar avatares =====
local playerNames = {}
if SKIP_REAL_PLAYERS then
    for _, p in ipairs(Players:GetPlayers()) do playerNames[p.Name] = true end
end

local models, seen = {}, {}
local function addAvatar(m)
    if seen[m.Address] then return end
    if not m:FindFirstChild("HumanoidRootPart") then return end
    if ONLY_NAME and m.Name ~= ONLY_NAME then return end
    if playerNames[m.Name] then return end
    seen[m.Address] = true
    table.insert(models, m)
end

for _, c in ipairs(workspace:GetChildren()) do
    addAvatar(c)
    if c.ClassName == "Folder" or (ONLY_NAME and c.Name == ONLY_NAME) then
        for _, sub in ipairs(c:GetChildren()) do addAvatar(sub) end
    end
end

print("[AVATAR] Avatars found: " .. #models)
if #models == 0 then return end

local avatars = {}
for _, m in ipairs(models) do
    local a = collect(m)
    table.insert(avatars, a)

    local hdCount = 0
    for _ in pairs(a.hdProps) do hdCount = hdCount + 1 end
    print(string.format(
        "[AVATAR] %s | rig=%s | userId=%s | accessory IDs=%d | body part IDs=%d | HumanoidDescription IDs=%d",
        a.name, a.rig, tostring(a.userId), #a.accessories, #a.bodyParts, hdCount
    ))
    if #a.accessories == 0 and #a.bodyParts == 0 and hdCount == 0 and not a.userId then
        print("[AVATAR] WARNING: " .. a.name .. " has no readable IDs and no userId. Add it to USER_IDS.")
    end
end

-- ===== Generar el script de Studio =====
local o = {}
local function add(s) o[#o + 1] = s end

add("-- Generated by Matcha avatar dumper")
add("-- Studio: View > Command Bar, paste and press Enter")
add("local Players = game:GetService('Players')")
add("local AVATARS = {")

for _, a in ipairs(avatars) do
    add("{")
    add("name = " .. q(a.name) .. ", rig = " .. q(a.rig) .. ", userId = " .. (a.userId or "nil") .. ",")

    local hd = {}
    for k, v in pairs(a.hdProps) do hd[#hd + 1] = k .. " = " .. v end
    add("hd = { " .. table.concat(hd, ", ") .. " },")

    local bps = {}
    for _, bp in ipairs(a.bodyParts) do
        bps[#bps + 1] = "{ part = " .. lit(bp.part) .. ", id = " .. bp.id .. " }"
    end
    add("bodyParts = { " .. table.concat(bps, ", ") .. " },")

    local accs = {}
    for _, acc in ipairs(a.accessories) do
        local f = { "id = " .. acc.id }
        if acc.type ~= nil then f[#f + 1] = "type = " .. lit(acc.type) end
        if acc.layered ~= nil then f[#f + 1] = "layered = " .. tostring(acc.layered) end
        if type(acc.order) == "number" then f[#f + 1] = "order = " .. acc.order end
        if type(acc.puff) == "number" then f[#f + 1] = "puff = " .. acc.puff end
        accs[#accs + 1] = "{ " .. table.concat(f, ", ") .. " }"
    end
    add("accessories = { " .. table.concat(accs, ", ") .. " },")

    local cols = {}
    for k, c in pairs(a.colors) do
        cols[#cols + 1] = string.format("%s = { %d, %d, %d }", k, c[1], c[2], c[3])
    end
    add("colors = { " .. table.concat(cols, ", ") .. " },")

    local scs = {}
    for k, v in pairs(a.scales) do scs[#scs + 1] = k .. " = " .. tostring(v) end
    add("scales = { " .. table.concat(scs, ", ") .. " },")
    add("},")
end

add("}")
add([==[
local function enumItem(enumType, v)
	if v == nil then return nil end
	for _, item in ipairs(enumType:GetEnumItems()) do
		if item.Value == v or item.Name == v then return item end
	end
	return nil
end

for i, a in ipairs(AVATARS) do
	local ok, err = pcall(function()
		local hd
		if a.userId then
			local okD, d = pcall(function()
				return Players:GetHumanoidDescriptionFromUserId(a.userId)
			end)
			if okD then hd = d end
		end
		hd = hd or Instance.new("HumanoidDescription")

		for k, v in pairs(a.hd) do hd[k] = v end
		for _, bp in ipairs(a.bodyParts) do
			local item = enumItem(Enum.BodyPart, bp.part)
			if item then hd[item.Name] = bp.id end
		end
		for k, c in pairs(a.colors) do hd[k] = Color3.fromRGB(c[1], c[2], c[3]) end
		for k, v in pairs(a.scales) do hd[k] = v end

		if #a.accessories > 0 then
			local list = {}
			for _, acc in ipairs(a.accessories) do
				local t = enumItem(Enum.AccessoryType, acc.type)
				if t then
					local e = { AssetId = acc.id, AccessoryType = t, IsLayered = acc.layered == true }
					if acc.order then e.Order = acc.order end
					if acc.puff then e.Puffiness = acc.puff end
					table.insert(list, e)
				end
			end
			hd:SetAccessories(list, true)
		end

		local model = Players:CreateHumanoidModelFromDescription(hd, Enum.HumanoidRigType[a.rig])
		model.Name = a.name
		model.Parent = workspace
		model:PivotTo(CFrame.new(i * 6, 6, 0))
		local root = model:FindFirstChild("HumanoidRootPart")
		if root then root.Anchored = true end
	end)
	if ok then
		print("Built: " .. a.name)
	else
		warn("Failed: " .. a.name .. " - " .. tostring(err))
	end
end
]==])

local code = table.concat(o, "\n")
local okClip = pcall(setclipboard, code)
local okFile = pcall(writefile, OUTPUT_FILE, code)
print("[AVATAR] Clipboard: " .. (okClip and "ok" or "failed") .. " | File " .. OUTPUT_FILE .. ": " .. (okFile and "ok" or "failed"))
notify("Avatar import script copied", "Avatar Dumper", 4)
