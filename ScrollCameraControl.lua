script_name('Scroll Camera Control')
script_author('chapo')

require('lib.moonloader')
local memory = require('memory')
local inicfg = require('inicfg')

local CCamera = 0xB6F028
local ini = inicfg.load({
    main = { fov = 70, dist = 2 }
}, 'ScrollCameraControlByChapo.ini')
inicfg.save(ini, 'ScrollCameraControlByChapo.ini')

function main()
    while not isSampAvailable() do wait(0) end
    while true do
        wait(0)
        if not sampIsCursorActive() and isKeyDown(VK_V) then
            printStringNow(('Usar ~y~SCROLL~w~ para cambiar la distancia (presionar ~y~ALT~w~ para cambiar FOV)~n~FOV: ~y~%s~w~~n~DIST: ~y~%s'):format(ini.main.fov, ini.main.dist), 10)
            if getMousewheelDelta() ~= 0 then
                local ALT = isKeyDown(VK_LMENU)
                ini.main[ALT and 'fov' or 'dist'] = ini.main[ALT and 'fov' or 'dist'] - getMousewheelDelta() * (ALT and 5 or 2)
                ini.main.fov = ini.main.fov > 120 and 120 or (ini.main.fov < 10 and 10 or ini.main.fov)
                ini.main.dist = ini.main.dist > 70 and 70 or (ini.main.dist < 1 and 1 or ini.main.dist)
                inicfg.save(ini, 'ScrollCameraControlByChapo.ini')
            end
        end
        local isAiming = isCharAiming(PLAYER_PED)
        setCameraDistance(isAiming and 1 or ini.main.dist)
        cameraSetLerpFov(isAiming and 70 or ini.main.fov, isAiming and 70 or ini.main.fov, 1000, 1)
    end
end

addEventHandler('onWindowMessage', function(msg, param)
    if msg == 0x0100 and param == VK_V then
        consumeWindowMessage(true, false)
    elseif msg == 0x020a and isKeyDown(VK_V) then
        consumeWindowMessage(true, false)
    end
end)

---@param ped number Player handler
---@retrun boolean Is aiming Is ped aiming
function isCharAiming(ped)
    return memory.getint8(getCharPointer(ped) + 0x528, false) == 19
end

---@param distance number Camera distance
function setCameraDistance(distance)
    memory.setuint8(CCamera + 0x38, 1)
	memory.setuint8(CCamera + 0x39, 1)
	memory.setfloat(CCamera + 0xD4, distance)
	memory.setfloat(CCamera + 0xD8, distance)
	memory.setfloat(CCamera + 0xC0, distance)
	memory.setfloat(CCamera + 0xC4, distance)
end