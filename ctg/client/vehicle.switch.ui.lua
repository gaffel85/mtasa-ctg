DGS = exports.dgs --shorten the export function prefix

local vehicleWindow = nil
local progressBar = nil
local vehiclesUi = {
    superCar = {
        button = nil,
        label = nil,
    },
    offroad = {
        button = nil,
        label = nil,
    },
    airplane = {
        button = nil,
        label = nil,
    },
}

local function createVehicleLabel(x, y, w, h, text)
    
end

local function createVehicleWindow()
    vehicleWindow = DGS:dgsCreateWindow(0.02, 0.5, 0.1, 0.1, "Swtich Vehicle", true)
    DGS:dgsSetProperty(vehicleWindow, "titleColor", tocolor(255, 255, 60, 255))
    progressBar = DGS:dgsCreateProgressBar(0.01, 0.8, 0.98, 0.2, true, vehicleWindow)

end

local function getVehicleWindow()
    if vehicleWindow == nil then
        vehicleWindow = createVehicleWindow()
    end
    return vehicleWindow
end