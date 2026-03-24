local isPerformingSuperCatchup = false

addEvent("startSuperCatchupSequence", true)
addEventHandler("startSuperCatchupSequence", resourceRoot, function(leader)
    outputConsole("[SCU-TRACE] startSuperCatchupSequence event received.")
    if isPerformingSuperCatchup then 
        outputConsole("[SCU-TRACE] Already performing Super Catch-Up.")
        return 
    end
    isPerformingSuperCatchup = true

    if not leader then
        -- try finding locally if not passed, but server should pass it
        leader = getGoldCarrier()
    end

    if not leader or not isElement(leader) then
        outputChatBox("No leader found for Super Catch-Up!", 255, 0, 0)
        outputConsole("[SCU-TRACE] No leader found.")
        isPerformingSuperCatchup = false
        return
    end
    outputConsole("[SCU-TRACE] Leader identified: " .. getPlayerName(leader))

    fadeCamera(false, 1.0)
    
    setTimer(function()
        outputConsole("[SCU-TRACE] Sequence starting: camera following " .. getPlayerName(leader))
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
            outputConsole("[SCU-TRACE] T=2s timer reached. Requesting teleport and switching camera to player.")
            countdown = 1
            if not isElement(leader) then
                outputConsole("[SCU-TRACE] ERROR: Leader element lost at T=2s.")
                -- We still want to follow the player if teleport fails for some reason
            else
                local lx, ly, lz = getElementPosition(leader)
                local lrx, lry, lrz = getElementRotation(leader)
                local lvx, lvy, lvz = getElementVelocity(leader)
                triggerServerEvent("onSuperCatchupTeleport", resourceRoot, lx, ly, lz, lrx, lry, lrz, lvx, lvy, lvz)
            end
            
            setCameraTarget(localPlayer)
        end, 2000, 1)
        
        -- Update countdown
        setTimer(function() 
            outputConsole("[SCU-TRACE] T=1s timer reached.")
            countdown = 2 
        end, 1000, 1)
        
        -- T = 3s: Release
        setTimer(function()
            outputConsole("[SCU-TRACE] T=3s timer reached. Restoring camera and requesting release.")
            countdown = 0
            removeEventHandler("onClientRender", root, drawCountdown)
            setCameraTarget(localPlayer)
            
            triggerServerEvent("onSuperCatchupRelease", resourceRoot)
            isPerformingSuperCatchup = false
        end, 3000, 1)
        
    end, 1000, 1)
end)
