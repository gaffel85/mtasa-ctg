local props = {
    consts = {
        tillbakaKakatime = 5000,
        repairTime = 5,
        presentGoldDeliveredTime = 7,
        goldMass = 1000,
        goldHeight = 2,
        goldHandlingCoeff = 0.8,
        damageMultiplierWeight = 1.0,
        moneyToOpponentsPercentage = 0.7,
    },
    powers = {
        nitro = {
            duration = 6,
            cooldown = 20,
            initCooldown = 5,
            allowedGoldCarrier = false,
            charges = 5,
            rank = 1,
        },
        teleport = {
            duration = 0,
            cooldown = 20,
            initCooldown = 8,
            allowedGoldCarrier = false,
            charges = 1,
            rank = 1,
            minDistance = 300,
        },
        waterLevel = {
            duration = 10,
            cooldown = 30,
            initCooldown = 1,
            allowedGoldCarrier = false,
            rank = 2,
        },
        helicopter = {
            duration = 8,
            cooldown = 20,
            initCooldown = 1,
            allowedGoldCarrier = false,
            charges = -1,
            rank = 5,
        },
        plane = {
            duration = 4,
            cooldown = 20,
            initCooldown = 1,
            allowedGoldCarrier = false,
            charges = 1,
            rank = 4,
        },
        offroad = {
            duration = 8,
            cooldown = 20,
            initCooldown = 1,
            allowedGoldCarrier = false,
            charges = -1,
            rank = 3,
        },
        superCar = {
            duration = 20,
            cooldown = 20,
            initCooldown = 10,
            allowedGoldCarrier = false,
            rank = 5,
            model = 541,
        },
        busses = {
            duration = 20,
            cooldown = 20,
            initCooldown = 10,
            allowedGoldCarrier = false,
            rank = 4,
        },
        shield = {
            duration = 6,
            cooldown = 3,
            initCooldown = 0,
            allowedGoldCarrier = true,
            charges = 3,
            rank = 3,
        },
        chaos = {
            duration = 16,
            cooldown = 20,
            initCooldown = 1,
            allowedGoldCarrier = false,
            rank = 4,
        },
        canon = {
            duration = 1,
            cooldown = 5,
            initCooldown = 1,
            allowedGoldCarrier = false,
            charges = 1,
            rank = 2,
        },
        cinematic = {
            duration = 3,
            cooldown = 3,
            initCooldown = 0,
            allowedGoldCarrier = true,
            rank = 3,
        }
    }
}

setElementData(resourceRoot, "props", props)

function getConst()
    return getElementData(resourceRoot, "props").consts
end

function getPowerConst()
    return getElementData(resourceRoot, "props").powers
end