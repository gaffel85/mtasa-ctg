function updateCamera ()
    --outputChatBox('Hello, world!'..inspect(getElementPosition(localPlayer)))
    for player, active in pairs(getShieldedPlayers()) do
        if active then
            --local player = localPlayer
            local vehicle = getPedOccupiedVehicle(player)
            if not vehicle then
                return
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
end
addEventHandler ( "onClientRender", root, updateCamera )