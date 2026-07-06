-- Cargar el script
loadstring(game:HttpGet("https://raw.githubusercontent.com/FOXTROXHACKS/Matcha/refs/heads/main/MISC/Tween_Service.lua"))()

-- Esperar a que el servicio esté disponible en _G
local MyTweenService = nil
repeat
    MyTweenService = _G.TweenService
    task.wait()
until MyTweenService

-- Ahora tu lógica de búsqueda
local spawnablesFolder = workspace:FindFirstChild("DebrisClient")

if spawnablesFolder then
    for i, v in pairs(spawnablesFolder:GetChildren()) do
        local touchPart = v:FindFirstChild("HitDetect")
        
        if touchPart and touchPart:IsA("Part") then
            local info = MyTweenService.TweenInfo.new(1.5, "Quad", "Out")
            local propiedades = { Position = touchPart.Position + Vector3.new(0, 5, 0) }
            
            local tween = MyTweenService:Create(touchPart, info, propiedades)
            tween:Play()
        end
    end
end
