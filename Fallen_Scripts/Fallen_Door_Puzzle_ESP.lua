--[[
_G.Bench_Config = {
    Enabled = true,
    BoxSize = 10,
    MaxDist = 500 -- meters
}
]]
local sys = "[SYS]: "
local cfg = _G.Bench_Config

print(sys .. "ESP Filtrado: Puertas, Power Cell Box y Power Button")
print("---------------------------------")
local lp = game:GetService("Players").LocalPlayer
local benchFolder = workspace:FindFirstChild("BenchSpawns")

if not benchFolder then return end

local benchESP = {}

local allowedObjects = {
    ["Yellow Keycard Door"] = Color3.fromRGB(255, 255, 0),
    ["Purple Keycard Door"] = Color3.fromRGB(160, 32, 240),
    ["Red Keycard Door"]    = Color3.fromRGB(255, 0, 0),
    ["Pink Keycard Door"]   = Color3.fromRGB(255, 105, 180),
    ["Black Keycard Door"]  = Color3.fromRGB(0, 255, 0), -- Verde Fluorescente
    ["Power Cell Box"]      = Color3.fromRGB(255, 255, 255), -- Blanco
    ["Power Button"]        = Color3.fromRGB(255, 255, 255)  -- Blanco
}

for _, obj in pairs(benchFolder:GetChildren()) do
    local itemColor = allowedObjects[obj.Name]
    if itemColor then
        local target = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
        if target then
            local box = Drawing.new("Square")
            box.Color = itemColor
            box.Thickness = 1
            box.Visible = false 
      
            local text = Drawing.new("Text")
            text.Color = itemColor
            text.Center = true
            text.Outline = true
            text.Size = 14
            text.Visible = false

            table.insert(benchESP, {target, box, text, obj.Name})
        end
    end
end

while true do
    task.wait(0)
    local rx, ry, rz = nil, nil, nil
    pcall(function()
        local rPos = lp.Character.HumanoidRootPart.Position
        rx, ry, rz = rPos.X, rPos.Y, rPos.Z
    end)
    
    for _, data in ipairs(benchESP) do
        local part, box, text, name = data[1], data[2], data[3], data[4]

        if cfg.Enabled and part and part.Parent then
            local hPos = part.Position
            local realMeters = 9999
            
            if rx and ry and rz then
                realMeters = (math.sqrt((hPos.X - rx)^2 + (hPos.Y - ry)^2 + (hPos.Z - rz)^2)) * 0.28
            end

            if realMeters <= cfg.MaxDist then
                local pos, onScreen = WorldToScreen(hPos)
                
                if onScreen and pos then
                    box.Size = Vector2.new(cfg.BoxSize, cfg.BoxSize)
                    box.Position = Vector2.new(pos.X - cfg.BoxSize/2, pos.Y - cfg.BoxSize/2)
                    box.Visible = true
                    
                    text.Text = name .. " [" .. math.floor(realMeters) .. "m]"
                    text.Position = Vector2.new(pos.X, pos.Y + (cfg.BoxSize/2) + 2)
                    text.Visible = true
                else
                    box.Visible = false
                    text.Visible = false
                end
            else
                box.Visible = false
                text.Visible = false
            end
        else
            box.Visible = false
            text.Visible = false
        end
    end
end
