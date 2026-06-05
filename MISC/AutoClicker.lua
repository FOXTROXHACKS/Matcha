local enabled=false
local cps=100
local clickType="left" 
local randomization=0
local burstCount=1
local burstDelay=10

local function doClick(button)
    button=button or "left"
    if button=="left" then
        mouse1click()
    elseif button=="right" then
        mouse2click()
    end
end

local function checkF3()
    if iskeypressed and iskeypressed(0x72) then
        return true
    end
    return false
end

local function autoClick()
    local lastF3State=false
    while true do
        local currentF3State=checkF3()
        if currentF3State and not lastF3State then
            enabled=not enabled
            wait(0.2)
            print(enabled and "[AC] ON" or "[AC] OFF")
        end
        lastF3State=currentF3State
        if enabled then
            local baseDelay=1/cps
            local delay=baseDelay
            if randomization>0 then
                local randomOffset=(math.random(2-1)(baseDelay*randomization/100))
                delay=math.max(0.01,baseDelay+randomOffset)
            end
            for i=1,burstCount do
                if enabled then
                    doClick(clickType)
                    if i<burstCount then wait(burstDelay/1000) end
                end
            end
            wait(delay)
        else
            wait(0.05)
        end
    end
end

spawn(autoClick)
print("[AC] Loaded | F3=Toggle | CPS:"..cps)
