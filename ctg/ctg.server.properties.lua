
local props = {
    consts = {
        goldSpawnDistance = 1200,
        goldSpawnSafeDistance = 300,
        goldSpawnMinDistance = 300,
        hideoutSpawnDistance = 1000,
        goldSpawnTime = 30,
        tillbakaKakatime = 5000,
        repairTime = 5,
        presentGoldDeliveredTime = 7,
        goldMass = 1000,
        goldHeight = 2,
        goldHandlingCoeff = 0.8,
        damageMultiplierWeight = 1.0,
        moneyToOpponentsPercentage = 0.7,
        airplaneQuota = 0,
        helicopterQuota = 0,
        door2Quota = 1,
        door4Quota = 1,
        civilQuota = 1,
        govermentQuota = 1,
        heavyQuota = 1,
        vansQuota = 1,
        suvQuota = 1,
        lowRidersQuota = 1,
        muscleQuota = 3,
        streetRacersQuota = 4,
        recreationalQuota = 2,
    },
    powers = {
        nitro = {
            duration = 8,
            cooldown = 21,
            initCooldown = 10,
            allowedGoldCarrier = false,
            charges = nil,
            rank = 1,
        },
        teleport = {
            duration = 0,
            cooldown = 20,
            initCooldown = 5,
            allowedGoldCarrier = false,
            charges = 1,
            rank = 1,
            minDistance = 300,
        },
        waterLevel = {
            duration = 10,
            cooldown = 20,
            initCooldown = 20,
            allowedGoldCarrier = false,
            charges = 2,
            rank = 5,
        },
        helicopter = {
            duration = 15,
            cooldown = 20,
            initCooldown = 15,
            allowedGoldCarrier = false,
            charges = 2,
            rank = 3,
        },
        plane = {
            duration = 12,
            cooldown = 20,
            initCooldown = 15,
            allowedGoldCarrier = false,
            charges = 2,
            rank = 2,
        },
        offroad = {
            duration = 10,
            cooldown = 30,
            initCooldown = 15,
            allowedGoldCarrier = true,
            charges = nil,
            rank = 2,
        },
        superCar = {
            duration = 10,
            cooldown = 30,
            initCooldown = 10,
            allowedGoldCarrier = false,
            charges = nil,
            rank = 4,
            model = 541,
        },
        busses = {
            duration = 10,
            cooldown = 35,
            initCooldown = 20,
            allowedGoldCarrier = false,
            charges = 2,
            rank = 3,
        },
        shield = {
            duration = 2000,
            cooldown = 10,
            initCooldown = 10,
            allowedGoldCarrier = true,
            charges = 1,
            rank = 4,
        },
        chaos = {
            duration = 16,
            cooldown = 60,
            initCooldown = 20,
            allowedGoldCarrier = false,
            charges = 2,
            rank = 5,
            switchTime = 4
        },
        canon = {
            duration = 1,
            cooldown = 20,
            initCooldown = 1,
            allowedGoldCarrier = false,
            charges = 3,
            rank = 4,
        },
        cinematic = {
            duration = 10,
            cooldown = 30,
            initCooldown = 10,
            allowedGoldCarrier = true,
            charges = 1,
            rank = 3,
        },
        hidemap = {
            duration = 5,
            cooldown = 40,
            initCooldown = 1,
            allowedGoldCarrier = true,
            charges = 1,
            rank = 2,
        },
    }
}

setElementData(resourceRoot, "props", props)

function getConst()
    return getElementData(resourceRoot, "props").consts
end

function getPowerConst()
    return getElementData(resourceRoot, "props").powers
end

-- funtion to get props based on passed key. It should support nested keys like "powers.nitro.duration"
function getProps(key)
    local keys = split(key, ".")
    local props = getElementData(resourceRoot, "props")
    local current = props
    for i, k in ipairs(keys) do
        current = current[k]
    end
    return current
end

-- function to update props based on passed key and value. It should support nested keys like "powers.nitro.duration"
function updateProps(key, value)
    local keys = split(key, ".")
    local props = getElementData(resourceRoot, "props")
    local current = props
    for i, k in ipairs(keys) do
        if i == #keys then
            current[k] = value
        else
            current = current[k]
        end
    end
    setElementData(resourceRoot, "props", props)
end