-- ctg/client/gold.visuals.lua

local goldShader = nil
local rotation = 0
local goldBarElement = nil

addEvent("onClientSetGoldElement", true)
addEventHandler("onClientSetGoldElement", root, function(el)
    goldBarElement = el
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    -- Load and replace model
    local txd = engineLoadTXD("goldbar.txd")
    if txd then
        engineImportTXD(txd, 1212)
    end
    
    local dff = engineLoadDFF("goldbar.dff")
    if dff then
        engineReplaceModel(dff, 1212)
    end

    -- Create and apply shader
    goldShader = dxCreateShader("gold_shader.fx")
    if goldShader then
        engineApplyShaderToWorldTexture(goldShader, "gold_tex_base")
    end

    -- Request gold element for late joiners
    triggerServerEvent("onClientRequestGoldElement", resourceRoot)
end)

addEventHandler("onClientPreRender", root, function(timeSlice)
    if not goldBarElement or not isElement(goldBarElement) then return end
    
    -- Smooth rotation calculation
    local rotationSpeed = 0.12 
    rotation = (rotation + rotationSpeed * timeSlice) % 360

    if getElementAttachedTo(goldBarElement) then
        -- If attached, update attachment offsets
        local ox, oy, oz, orx, ory, orz = getElementAttachedOffsets(goldBarElement)
        setElementAttachedOffsets(goldBarElement, ox, oy, oz, orx, ory, rotation)
    else
        -- If on ground, update world rotation
        setElementRotation(goldBarElement, 0, 0, rotation)
    end
end)
