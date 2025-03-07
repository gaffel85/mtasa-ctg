BOOST_COOLDOWN = 20
NITRO_DURATION = 6
TELEPORT_COOLDOWN = 20
CLOAK_COOLDOWN = 20
CLOAK_DURATION = 6
SWITCH_EXTRA_TIME = 10
REPAIR_TIME = 5
PRESENT_WINNER_TIME = 7
ALL_SEE_BOMB_HOLDER = true
CLOAK_HIDES_CAR = false
DISTANCE_FOR_STRESS_SOUND = 70
DISTANCE_FOR_ACTIVATING_STRESS_CHECK = 100
GOLD_MASS = 1000
GOLD_HEIGHT = 2
GOLD_HANDLING_COEFF = 0.8
DAMAGE_MULTIPLIER_WEIGHT = 1.0
TELEPORT_MIN_DISTANCE = 300
SUPER_CAR_MODEL = 541
MONEY_TO_OPPONENTS_PERCENTAGE = 0.7

local props = {
    consts = {
        tillbakaKakatime = 5000
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