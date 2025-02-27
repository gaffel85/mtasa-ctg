local shieldedPlayers = {}

function onShieldAdded(player)
    outputChatBox('Shield added')
    shieldedPlayers[player] = true
end
addEvent("onShieldAddedFromServer", true)
addEventHandler("onShieldAddedFromServer", localPlayer, onShieldAdded)

function onShieldRemoved(player)
    outputChatBox('Shield removed')
    shieldedPlayers[player] = nil
end
addEvent("onShieldRemovedFromServer", true)
addEventHandler("onShieldRemovedFromServer", localPlayer, onShieldRemoved)

function updateCamera ()
    for player, active in pairs(shieldedPlayers) do
        if not active then
            continue
        end

        local vehicle = getPedOccupiedVehicle(player)
        if not vehicle then
            continue
        end
        local x, y, z = getElementPosition(vehicle)
        local minx, miny, minz, maxx, maxy, maxz = getElementBoundingBox(vehicle)
        --local color = tocolor(math.random(0, 255), math.random(0, 255), math.random(0, 255), math.random(0, 255))
        local color = tocolor(255, 255, 255, 255)
        --outputChatBox('Hello, world!'..inpect(getElementPosition(localPlayer)))
        
        --find raduis that inclueds all bounding box
        local radius = math.max(maxx - minx, maxy - miny, maxz - minz) / 2
    
        dxDrawWiredSphere(x, y, z, radius, color, 0.5, 2)
    end
end
addEventHandler ( "onClientRender", root, updateCamera )