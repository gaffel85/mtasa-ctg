local isPerformingSuperCatchup = false

addEvent("startSuperCatchupSequence", true)
addEventHandler("startSuperCatchupSequence", resourceRoot, function()
    if isPerformingSuperCatchup then return end
    isPerformingSuperCatchup = true

    local leader = findLeader(localPlayer)
    if not leader then
        outputChatBox("No leader found for Super Catch-Up!", 255, 0, 0)
        isPerformingSuperCatchup = false
        return
    end

    fadeCamera(false, 1.0)
    
    setTimer(function()
        fadeCamera(true, 1.0)
        setCameraTarget(leader)
        
        local countdown = 3
        local screenW, screenH = guiGetScreenSize()
        
        local function drawCountdown()
            if countdown > 0 then
                dxDrawText(tostring(countdown), 0, 0, screenW, screenH, tocolor(255, 255, 255, 255), 5, "default-bold", "center", "center")
            end
        end
        addEventHandler("onClientRender", root, drawCountdown)
        
        -- T = 2s: Teleport and Freeze
        setTimer(function()
            countdown = 1
            local lx, ly, lz = getElementPosition(leader)
            local lrx, lry, lrz = getElementRotation(leader)
            local lvx, lvy, lvz = getElementVelocity(leader)
            
            triggerServerEvent("onSuperCatchupTeleport", resourceRoot, lx, ly, lz, lrx, lry, lrz, lvx, lvy, lvz)
        end, 2000, 1)
        
        -- Update countdown
        setTimer(function() countdown = 2 end, 1000, 1)
        
        -- T = 3s: Release
        setTimer(function()
            countdown = 0
            removeEventHandler("onClientRender", root, drawCountdown)
            setCameraTarget(localPlayer)
            triggerServerEvent("onSuperCatchupRelease", resourceRoot)
            isPerformingSuperCatchup = false
        end, 3000, 1)
        
    end, 1000, 1)
end)
