local TARGET_DATA_KEY = "TARGET_DATA_KEY"

function setPlayerMovingTarget(player, targetElement)
    local position = getElementPosition(targetElement)
    setElementData(player, TARGET_DATA_KEY, { element = targetElement, isStatic = false })
end

function setPlayerStaticTarget(player, x, y, z)
    setElementData(player, TARGET_DATA_KEY, { x = x, y = y, z = z, isStatic = true })
end

function getPlayerCurrentTarget(player)
    return getElementData(player, TARGET_DATA_KEY)
end

function getPlayerCurrentTargetPos(player)
    local target = getPlayerCurrentTarget(player)
    if target then
        if target.isStatic then
            return target.x, target.y, target.z
        else
            local x, y, z = getElementPosition(target.element)
            return x, y, z
        end
    end
    return nil, nil, nil
end