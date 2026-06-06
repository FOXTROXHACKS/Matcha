local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local mouse = LP:GetMouse()
local ctrl = 0x11
local debounce = false

while true do
    task.wait(0.05)
    if ismouse1pressed() and iskeypressed(ctrl) and not debounce then
        debounce = true
        local mouseX = mouse.X
        local mouseY = mouse.Y
        print("Click" .. mouseX .. ", " .. mouseY)
        local closest = nil
        local closestDist = math.huge
        for _, v in pairs(workspace:GetDescendants()) do
            local pos = nil
            if v.ClassName == "Part" or v.ClassName == "MeshPart" or v.ClassName == "UnionOperation" or v.ClassName == "SpecialMesh" then
                pos = v.Position
            elseif v.ClassName == "Model" then
                if v.PrimaryPart then
                    pos = v.PrimaryPart.Position
                end
            end
            if pos then
                local screenPos, onScreen = WorldToScreen(pos)
                if onScreen then
                    local dx = screenPos.X - mouseX
                    local dy = screenPos.Y - mouseY
                    local dist = math.sqrt(dx*dx + dy*dy)
                    if dist < closestDist then
                        closestDist = dist
                        closest = v
                    end
                end
            end
        end
        if closest then
            print("Name: " .. closest.Name)
            print("Class: " .. closest.ClassName)
            print("Parent: " .. tostring(closest.Parent and closest.Parent.Name or "nil"))
            print("Path: " .. closest:GetFullName())
        else
            print("No target visible")
        end
    elseif not ismouse1pressed() then
        debounce = false
    end
end
