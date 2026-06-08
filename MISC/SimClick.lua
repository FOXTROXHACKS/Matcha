local function SimClick(posx,posy)
    if mousemoveabs and mouse1click then
        mousemoveabs(posx, posy) -- Movimiento inicial
        task.wait(0.5)
        mousemoveabs(posx +1, posy) --Simualar Hover
        task.wait(0.5)
        mouse1click()--click
        print("[LOG] Click: " .. posx .. ", " .. posy)
    else
        warn("Las funciones de mouse no están disponibles en este entorno.")
    end
end
--task.wait(2)
--SimClick(1585, 551)
