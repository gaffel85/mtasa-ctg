local savedData = {}

function savePlayerState(player)
    local serial = getPlayerSerial(player)
    local score = getElementData(player, "Score")
    outputServerLog("[PERSISTENCE] Raw Score element data for " .. getPlayerName(player) .. ": " .. tostring(score))
    
    local team = nil
    if getCtgTeam then
        team = getCtgTeam(player)
    end
    local teamName = team and team.team and getTeamName(team.team)
    
    local vehicle = getPedOccupiedVehicle(player)
    local x, y, z, rx, ry, rz, model
    if vehicle then
        x, y, z = getElementPosition(vehicle)
        rx, ry, rz = getElementRotation(vehicle)
        model = getElementModel(vehicle)
    else
        x, y, z = getElementPosition(player)
        rx, ry, rz = getElementRotation(player)
        model = getCurrentVehicle and getCurrentVehicle() or 415
    end

    savedData[serial] = {
        score = score or 0,
        teamName = teamName,
        pos = {x, y, z},
        rot = {rx, ry, rz},
        model = model,
        tick = getTickCount()
    }
    outputServerLog("[PERSISTENCE] Saved state for " .. getPlayerName(player) .. " - Score: " .. tostring(savedData[serial].score) .. ", Team: " .. tostring(teamName) .. ", Model: " .. tostring(model))
end

function getSavedPlayerState(player)
    local serial = getPlayerSerial(player)
    return savedData[serial]
end

function clearSavedPlayerState(player)
    local serial = getPlayerSerial(player)
    savedData[serial] = nil
end

addEventHandler("onPlayerQuit", root, function()
    savePlayerState(source)
end, true, "high")
