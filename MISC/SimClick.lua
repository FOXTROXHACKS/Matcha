local mousepos = Vector2.new(1585, 551)
local function PerformSafeClick()
    if mousemoveabs and mouse1click then
        mousemoveabs(mousepos.X, mousepos.Y) -- Movimiento inicial
        task.wait(0.1)
        mousemoveabs(mousepos.X, mousepos.Y) --Simualar Hover
        task.wait(0.5)
        mouse1click()--click
        print("[LOG] Click ejecutado en: " .. tostring(mousepos))
    else
        warn("Las funciones de mouse no están disponibles en este entorno.")
    end
end
