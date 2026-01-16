--[[
_G.Drops_Config = {
    Enabled = true,
    BoxSize = 10,
    MaxDist = 5000
}
]]
local sys = "[SYS]: "
local cfg = _G.Drops_Config

print(sys .. "ESP Filtrado: Keycards en Drops (Anclado a Main)")
print("---------------------------------")
local lp = game:GetService("Players").LocalPlayer
local dropsFolder = workspace:FindFirstChild("Drops")

if not dropsFolder then return end

local dropsESP = {}

local allowedObjects = {
    ["Yellow Keycard"] = Color3.fromRGB(255, 255, 0),
    ["Purple Keycard"] = Color3.fromRGB(160, 32, 240),
    ["Red Keycard"]    = Color3.fromRGB(255, 0, 0),
    ["Pink Keycard"]   = Color3.fromRGB(255, 105, 180),
    ["Black Keycard"]  = Color3.fromRGB(0, 255, 0)
}

for _, obj in pairs(dropsFolder:GetChildren()) do
    local itemColor = allowedObjects[obj.Name]
    if itemColor then
        -- Buscamos el hijo llamado "Main" como pediste
        local target = obj:FindFirstChild("Main")
        
        if target and target:IsA("BasePart") then
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

            table.insert(dropsESP, {target, box, text, obj.Name})
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
    
    for _, data in ipairs(dropsESP) do
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
