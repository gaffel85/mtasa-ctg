-- ctg/client/gold.visuals.lua

local goldShader = nil
local rotation = 0
local goldBarElement = nil
local TARGET_MODEL_ID = 1212 

addEvent("onClientSetGoldElement", true)
addEventHandler("onClientSetGoldElement", root, function(el)
    goldBarElement = el
    -- Apply shader specifically to the gold element
    if goldShader and el then
        engineApplyShaderToWorldTexture(goldShader, "gold_tex_base", el)
    end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    -- Load and replace model
    local txd = engineLoadTXD("goldbar.txd")
    if txd then
        engineImportTXD(txd, TARGET_MODEL_ID)
    end
    
        local dff = engineLoadDFF("goldbar.dff")
        if dff then
            engineReplaceModel(dff, TARGET_MODEL_ID)
        end

    -- Create shader
    goldShader = dxCreateShader("gold_shader.fx")

    -- Request gold element
    triggerServerEvent("onClientRequestGoldElement", resourceRoot)
end)

addEventHandler("onClientPreRender", root, function(timeSlice)
    if not goldBarElement or not isElement(goldBarElement) then return end
    
    -- 1. Smooth rotation calculation
    local rotationSpeed = 0.12 
    rotation = (rotation + rotationSpeed * timeSlice) % 360

    -- 2. Handle Carrier-Specific Scale (Smaller bar for carrier visibility)
    local carrier = getGoldCarrier()
    if carrier == localPlayer then
        if getObjectScale(goldBarElement) ~= 1.67 then
            setObjectScale(goldBarElement, 1.67)
        end
    else
        if getObjectScale(goldBarElement) ~= 5.0 then
            setObjectScale(goldBarElement, 5.0)
        end
    end

    -- 3. Apply rotation
    if getElementAttachedTo(goldBarElement) then
        -- If attached, update attachment offsets
        local ox, oy, oz, orx, ory, orz = getElementAttachedOffsets(goldBarElement)
        setElementAttachedOffsets(goldBarElement, ox, oy, oz, orx, ory, rotation)
    else
        -- If on ground, update world rotation
        setElementRotation(goldBarElement, 0, 0, rotation)
    end
end)
