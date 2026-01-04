--CONFIGURACION
--[[
_G.ESP_Config = {
    Stone = true,
    Metal = false,
    Phosphate = false,
    BoxSize = 10,
    MaxDist = 200
}
]]
--Logs
local sys = "[SYS]: "
local cfg = _G.ESP_Config
local Stone_Val = ("Stone: "..tostring(cfg.Stone))
local Metal_Val = ("Metal: "..tostring(cfg.Metal))
local Phosphate_Val = ("Phosphate: "..tostring(cfg.Phosphate))
local Dist_Val = ("MaxDist: "..tostring(cfg.MaxDist).."m")

print(sys.."Cargando ESP de Nodos (Metros Reales + Límite)")
print("---[Settings]".." - "..Stone_Val.." - "..Metal_Val.." - "..Phosphate_Val.." - "..Dist_Val)
print("---------------------------------")

local lp = game:GetService("Players").LocalPlayer
local nodesFolder = workspace:FindFirstChild("Nodes")

if not nodesFolder then 
    print(sys.."Error - No se encontró la carpeta 'Nodes'")
    return 
end

local nodeESP = {}

for _, node in pairs(nodesFolder:GetChildren()) do
    local config = nil
    local nodeType = ""
    
    if node.Name == "Stone_Node" then
        config = {Color = Color3.fromRGB(0, 255, 0), Name = "Stone"}
        nodeType = "Stone"
    elseif node.Name == "Metal_Node" then
        config = {Color = Color3.fromRGB(255, 165, 0), Name = "Metal"}
        nodeType = "Metal"
    elseif node.Name == "Phosphate_Node" then
        config = {Color = Color3.fromRGB(255, 255, 0), Name = "Phosphate"}
        nodeType = "Phosphate"
    end

    if config then
        local mainPart = node:FindFirstChild("Main")
        if mainPart and mainPart:IsA("BasePart") then
            local box = Drawing.new("Square")
            box.Filled = false
            box.Color = config.Color
            box.Visible = false 

            local text = Drawing.new("Text")
            text.Color = config.Color
            text.Center = true
            text.Visible = false
            text.Outline = true
            text.Size = 14

            table.insert(nodeESP, {mainPart, box, text, nodeType, config.Name})
        end
    end
end

print(sys.."ESP configurado para " .. #nodeESP .. " nodos.")

while true do
    task.wait(0)
    local config = _G.ESP_Config 
    local currentSize = config.BoxSize or 10
    local maxDistanceMeters = config.MaxDist or 200

    local rx, ry, rz = nil, nil, nil
    pcall(function()
        local rPos = lp.Character.HumanoidRootPart.Position
        rx, ry, rz = rPos.X, rPos.Y, rPos.Z
    end)
    
    for _, data in ipairs(nodeESP) do
        local part = data[1]
        local box = data[2]
        local text = data[3]
        local nType = data[4]
        local bName = data[5]

        if config[nType] == true and part and part.Parent then
            local hPos = nil
            pcall(function() hPos = part.Position end)
            
            if hPos then
                local studsDist = 99999
                if rx and ry and rz then
                    pcall(function()
                        studsDist = math.sqrt((hPos.X - rx)^2 + (hPos.Y - ry)^2 + (hPos.Z - rz)^2)
                    end)
                end

                local realMeters = studsDist * 0.28

                if realMeters <= maxDistanceMeters then
                    local pos, onScreen = WorldToScreen(hPos)
                    
                    if onScreen and pos then
                        box.Size = Vector2.new(currentSize, currentSize)
                        box.Position = Vector2.new(pos.X - currentSize/2, pos.Y - currentSize/2)
                        box.Visible = true
                        
                        text.Text = bName .. " [" .. math.floor(realMeters) .. "m]"
                        text.Position = Vector2.new(pos.X, pos.Y + (currentSize/2) + 2)
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
        else
            box.Visible = false
            text.Visible = false
        end
    end
end

