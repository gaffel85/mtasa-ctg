-- ctg/client/temp_power_input.lua
-- Client-side module for handling player input to use temporary power-ups.

local KEY_BINDING = "x" -- The key to bind for using temporary power-ups

-- Bind the key when the client resource starts
addEventHandler("onClientResourceStart", resourceRoot, function()
    bindKey(KEY_BINDING, "down", function()
        -- Trigger a server event to request using the power-up
        triggerServerEvent("onUseTemporaryPowerupServer", localPlayer)
    end)
    
    outputChatBox("Temporary power-up activation bound to key: " .. KEY_BINDING, 0, 255, 0)
end)

-- Unbind the keys when the client resource stops
addEventHandler("onClientResourceStop", resourceRoot, function()
    unbindKey(KEY_BINDING, "down")
end)
