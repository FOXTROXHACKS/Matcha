local player = game.Players.LocalPlayer
local character = player.Character
local hrp = character and character:FindFirstChild("HumanoidRootPart")

-- Usamos pcall por si el mapa de Summerfest no está cargado en ese momento, para que el script no arroje errores.
local success, targetPlatform = pcall(function()
    return workspace.Interiors["MainMap!Summerfest"].SummerMap.Pedestals.StumpPedestal_Item_Summer_6.Platform
end)

if success and targetPlatform and hrp then
    -- Detenemos cualquier movimiento y teletransportamos al personaje un poco más arriba de la plataforma (+3 en el eje Y) para evitar que se quede atascado
    hrp.Velocity = Vector3.new(0, 0, 0)
    hrp.CFrame = targetPlatform.CFrame + Vector3.new(0, 3, 0)
else
    warn("No se pudo encontrar la plataforma o tu personaje no ha cargado.")
end
