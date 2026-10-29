local Players = game:GetService("Players")
local player = Players.LocalPlayer

local doorsFolder = workspace:WaitForChild("HalloweenDoors")

local running = false
local delayBetweenDoors = 3

local function teleportToDoors()
    running = true

    for _, door in ipairs(doorsFolder:GetChildren()) do
        if not running then
            break
        end

        local collider = door:FindFirstChild("ClickCollider", true)

        if collider and collider:IsA("BasePart") then
            local character = player.Character
                or player.CharacterAdded:Wait()

            local root = character:WaitForChild("HumanoidRootPart")

            -- Posicionarse frente al collider y mirar hacia él
            local targetPosition = collider.Position + collider.CFrame.LookVector

            root.CFrame = CFrame.lookAt(
                targetPosition,
                collider.Position
            )

            task.wait(delayBetweenDoors)
        end
    end

    running = false
    print("Recorrido terminado.")
end

teleportToDoors()
