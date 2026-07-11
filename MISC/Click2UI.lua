local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local mouse = LP:GetMouse()
local shift = 0x10
local debounce = false

while true do
    task.wait(0.05)
    if ismouse1pressed() and iskeypressed(shift) and not debounce then
        debounce = true
        local mouseX = mouse.X
        local mouseY = mouse.Y
        print("Click " .. mouseX .. ", " .. mouseY)

        local closest = nil
        local closestDist = math.huge

        for _, v in pairs(LP.PlayerGui:GetDescendants()) do
            if v.ClassName == "ImageButton" or v.ClassName == "TextButton"
            or v.ClassName == "TextLabel" or v.ClassName == "ImageLabel" then
                local ok, absPos = pcall(function() return v.AbsolutePosition end)
                local ok2, absSize = pcall(function() return v.AbsoluteSize end)
                if ok and ok2 and absPos and absSize then
                    local cx = absPos.X + absSize.X / 2
                    local cy = absPos.Y + absSize.Y / 2
                    local dx = cx - mouseX
                    local dy = cy - mouseY
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
