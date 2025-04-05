PowerStateRepo = {
    states = {}, -- Internal state to store power states for players
}

function PowerStateRepo:initPowerState(player, powerUp, initialState)
    local playerStates = self.states[player]
    if not playerStates then
        playerStates = {}
        self.states[player] = playerStates
    end

    local powerUpState = {
        state = initialState,
        endTime = nil,
        timeLeftOnPause = nil,
        stateMessage = nil,
        stateBeforePause = nil,
        charges = powerUp.charges(),
        timer = nil
    }
    playerStates[powerUp.key] = powerUpState

    return powerUpState
end

local function getKey(powerUp)
    --if powerUp.shareState then
    --    return powerUp.resourceKey
    --end
    return powerUp.key
end

function PowerStateRepo:getPowerState(player, powerUp)
    local playerStates = self.states[player]
    if not playerStates then
        return nil
    end

	local powerUpState = playerStates[getKey(powerUp)]
	return powerUpState
end

function PowerStateRepo:clearStateForPlayer(player)
    self.states[player] = {}
end

function PowerStateRepo:removeStateForPlayer(player)
    self.states[player] = nil
end