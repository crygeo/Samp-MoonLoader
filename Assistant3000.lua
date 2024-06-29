script_name('Asistente Samp')
script_version('0.0.1')
script_author('CryGeo')
script_description('Puedes crear macros/acciones/funcione de muchas formas.')


_G.HOTKEY_USADOS = {}

local dkjson = require("lib/dkjson-master/dkjson")

local imgui = require 'src/imple/mimgui'
local helpMet = require("src/imple/helpMet")
local vk = require 'src/imple/keysC'
local ffi = require 'ffi'
local memory = require'memory'
local encoding = require 'encoding'

local new = imgui.new

encoding.default = 'iso-8859-1'
local u8 = encoding.UTF8

local URL = "src/data.json"


local font_flag = require('moonloader').font_flag
local my_font = renderCreateFont('Verdana', 12, font_flag.BOLD + font_flag.SHADOW)

local vConfig = require'src/view/vConfig'
local vMacroCrud = require'src/view/vMacroCrud'






thread_GrabarKey = lua_thread.create_suspended(
        function(modelo_v) 
            modelo_v.buttonText = "Detener Grabacion"
            modelo_v.grabando = true
            modelo_v.keysActivate = {}
            modelo_v.labelKeysActivate = ""

            while (modelo_v.grabando) do 
                local key = vk.get_key_pressed()
                local insert = true

                if(key ~= nil and not helpMet.existe_en_lista(modelo_v.keysActivate, key)) then
                    
                    if(key.category ~= vk.categorys.KeyAccion) then 
                        modelo_v.grabando = false 
                        modelo_v.buttonText = "Grabar KeyHot"
                    end
                    
                    if(key.category == vk.categorys.KeyAccion and #modelo_v.keysActivate >= 2) then 
                        modelo_v.grabando = true
                        insert = false
                    end
                    
                    if(insert) then 
                        table.insert(modelo_v.keysActivate, key)
                        if(modelo_v.keysActivate ~= nil) then
                            modelo_v.labelKeysActivate = vk.parse_array_keys_from_string(modelo_v.keysActivate)
                        end
                    end
                end
            end
        end
)

_G.GLOBAL_DATA = {}

function main()
    --cargar datos del json
    GLOBAL_DATA = helpMet.GetDataArchivo(URL)

    if GLOBAL_DATA == nil then
        GLOBAL_DATA = {}
        GLOBAL_DATA.settings = {
            macrosOn = true,
            accionesOn = true,
            subComandosOn = true,
            servicesOn = true,
        }
    end
    
    vConfig.CargarSettings(GLOBAL_DATA.settings)

    while not isSampAvailable() do wait(50) end
    
    CargarCommandosGlobal()
    CargarMacros()
    CargarAction()
    CargarSubCommand()
    
end

function carFind()
    local result, posX, posY, posZ = getTargetBlipCoordinates()
    if result then
        sampAddChatMessage("X: " .. posX .. " | Y: " .. posY .. " | Z: " .. posZ, -1)
    else
        sampAddChatMessage("Marker not found", -1)
    end
end


lua_thread.create(function()

    local buscarEnable = false
    local idCarBuscar = 0

    while true do
        if buscarEnable then

            local isOn, micar2 = sampGetCarHandleBySampVehicleId(idCarBuscar)
            if isOn then
                local vehiculoX, vehiculoY, vehiculoZ = getCarCoordinates(micar2)
                local playerX, playerY, playerZ = getCharCoordinates(PLAYER_PED)
                local dista = calcularDistancia(vehiculoX, vehiculoY, vehiculoZ, playerX, playerY, playerZ)
                renderFontDrawText(my_font, 'Distancia: ' .. dista ,  10, 470, 0xFFFFFFFF)
            else
                renderFontDrawText(my_font, 'Fuera de area.' ,  10, 470, 0xFFFFFFFF)
            end
        end
        --dibujarRectanguloAlrededorDeVehiculo(micar2)
        wait(0)
    end
end)

function buscarCarro(arg)
    print(arg)
    if #arg == 0 then
        buscarEnable = false
    else
        buscarEnable = true
        idCarBuscar = tonumber(arg)
    end
end
    
function calcularDistancia(vehiculoX, vehiculoY, vehiculoZ, jugadorX, jugadorY, jugadorZ)

    local distanciaX = vehiculoX - jugadorX
    local distanciaY = vehiculoY - jugadorY

    local distancia = math.sqrt(distanciaX^2 + distanciaY^2)
    return math.floor(distancia * 100) / 100 -- Redondear al entero más cercano
end

function calculateAngle(A, B, C)
    -- Calcular los cuadrados de las longitudes de los lados
    local AB = {x = B.x - A.x, y = B.y - A.y}
    local BC = {x = C.x - B.x, y = C.y - B.y}

    local dotProduct = AB.x * BC.x + AB.y * BC.y
    local magnitudeAB = math.sqrt(AB.x^2 + AB.y^2)
    local magnitudeBC = math.sqrt(BC.x^2 + BC.y^2)

    local cosTheta = dotProduct / (magnitudeAB * magnitudeBC)
    local theta = math.acos(cosTheta)

    return math.deg(theta)
end

function calculateAngleBetweenVectors(vectorA, vectorB, vectorC)
    -- Calcular las longitudes de los lados del triángulo formado por los vectores
    local lengthA = math.sqrt(vectorA.x^2 + vectorA.y^2 + vectorA.z^2)
    local lengthB = math.sqrt(vectorB.x^2 + vectorB.y^2 + vectorB.z^2)
    local lengthC = math.sqrt(vectorC.x^2 + vectorC.y^2 + vectorC.z^2)

    -- Calcular los productos punto entre los vectores
    local dotAB = vectorA.x * vectorB.x + vectorA.y * vectorB.y + vectorA.z * vectorB.z
    local dotBC = vectorB.x * vectorC.x + vectorB.y * vectorC.y + vectorB.z * vectorC.z
    local dotCA = vectorC.x * vectorA.x + vectorC.y * vectorA.y + vectorC.z * vectorA.z

    -- Calcular los ángulos entre los vectores
    local angleA = math.acos(dotBC / (lengthB * lengthC))
    local angleB = math.acos(dotCA / (lengthC * lengthA))
    local angleC = math.acos(dotAB / (lengthA * lengthB))

    -- Convertir los ángulos de radianes a grados
    angleA = math.deg(angleA)
    angleB = math.deg(angleB)
    angleC = math.deg(angleC)
    return angleA, angleB, angleC
end

local tit = ""
local str = ""
local did
local st

function onReceiveRpc(id, bs)
    --print("Id: " .. id)
    --print("Bs: " .. bs)

    --[ML] (script) Asistente Samp: Id: 61
    --[ML] (script) Asistente Samp: Bs: 24637332
	if id == 61 then 
        did = raknetBitStreamReadInt16(bs) -- paquete
        st =  raknetBitStreamReadInt8(bs) -- id
		tit = raknetBitStreamReadString(bs, raknetBitStreamReadInt8(bs)) -- titulo
        local btn1 = raknetBitStreamReadString(bs, raknetBitStreamReadInt8(bs))  --buton 1
        local btn2 = raknetBitStreamReadString(bs, raknetBitStreamReadInt8(bs)) -- buton 2
        str = raknetBitStreamDecodeString(bs, 4096) -- texto
        
        if(helpMet.contains(tit, GLOBAL_DATA.services.inventario.title)) then
            openViewInventario(tit, str)
            return false
        end
	end
end

function openViewInventario(tit, str)

    vInventory.description = str
    vInventory.visible[0] = not vInventory.visible[0]

    
end

local function send(p)
	local bs = raknetNewBitStream()
	raknetBitStreamWriteInt16(bs, did)
	raknetBitStreamWriteInt8(bs, 1)
	raknetBitStreamWriteInt16(bs, 0)
	raknetBitStreamWriteInt8(bs, #p)
	raknetBitStreamWriteString(bs, p)
	raknetSendRpcEx(62, bs, 1, 9, 0, 0)
	raknetDeleteBitStream(bs)
	did = nil
	tit = nil 
	st = nil
end

addEventHandler('onWindowMessage', function(msg, wparam)
    --print("msg: " .. msg)
    --print("wparm: " .. wparam)

    --[ML] (script) Asistente Samp: wparm: 73
    --[ML] (script) Asistente Samp: msg: 258
    --[ML] (script) Asistente Samp: wparm: 105
    --[ML] (script) Asistente Samp: msg: 275
	
end)

function dibujarRectanguloAlrededorDeVehiculo(car)
    local vehiculoX, vehiculoY, vehiculoZ = getCarCoordinates(car)
    local camaraX, camaraY, camaraZ = getActiveCameraPointAt()
    local playerX, playerY, playerZ = getCharCoordinates(PLAYER_PED)

    local vector1 = {
        x = vehiculoX,
        y = vehiculoY,
        z = vehiculoZ
    }

    local vector2 = {
        x = camaraX,
        y = camaraY,
        z = camaraZ
    }

    local vector3 = {
        x = playerX,
        y = playerY,
        z = playerZ
    }


    local X, Y = getScreenResolution()


    renderFontDrawText(my_font, camaraX,  10, 400, 0xFFFFFFFF)
    renderFontDrawText(my_font, camaraY,  10, 420, 0xFFFFFFFF)
    renderFontDrawText(my_font, camaraZ,  10, 440, 0xFFFFFFFF)
    
    local puntoCarX, puntoCarY = 500 , 300
    local anchoRectangulo, altoRectangulo = 250, 150
    local dista = calcularDistancia(vehiculoX, vehiculoY, vehiculoZ, playerX, playerY, playerZ)
    local distb = calcularDistancia(playerX, playerY, playerZ, camaraX, camaraY, camaraZ)
    local distc = calcularDistancia(camaraX, camaraY, camaraZ, vehiculoX, vehiculoY, vehiculoZ)
    local angle1, angle2, angle3 = calculateAngleBetweenVectors(vector1, vector2, vector3)
    local angle = calculateAngle(vector1, vector3, vector2)

    renderFontDrawText(my_font, 'Distancia1: ' .. dista ,  10, 470, 0xFFFFFFFF)
    renderFontDrawText(my_font, 'Distancia2: ' .. distb ,  10, 490, 0xFFFFFFFF)
    renderFontDrawText(my_font, 'Distancia3: ' .. distc ,  10, 510, 0xFFFFFFFF)

    renderFontDrawText(my_font, 'Angulo1 : ' .. angle1 ,  10, 550 , 0xFFFFFFFF)
    renderFontDrawText(my_font, 'Angulo2 : ' .. angle2 ,  10, 570 , 0xFFFFFFFF)
    renderFontDrawText(my_font, 'Angulo3 : ' .. angle3 ,  10, 590 , 0xFFFFFFFF)
    renderFontDrawText(my_font, 'Angulo0 : ' .. angle ,  10, 610 , 0xFFFFFFFF)

    -- Calcular las coordenadas del rectángulo
    local x1 = ((X - camaraZ)/2) - (anchoRectangulo / 2) / dista
    local y1 = ((Y - camaraZ)/2) - (altoRectangulo / 2) / dista
    local x2 = anchoRectangulo / dista
    local y2 = altoRectangulo / dista

    -- Dibujar el rectángulo
    renderDrawBoxWithBorder(x1, y1, x2, y2, 0xffff, 3, 0x90000000)
end

function separarTexto(inputString)
    local result = {}

    local section = ""
    local insert = false
    for char in inputString:gmatch(".") do
        
        if char == "{" then
            table.insert( result, section)
            section = char
        elseif char == "}" then
            table.insert( result, section .. char)
            section = ""
        else 
            section = section .. char
        end

    end
    table.insert( result, section)
    return result
end

function verificarLlaves(texto)
    local apertura = texto:gsub("[^{]", "")
    local cierre = texto:gsub("[^}]", "")
    return apertura == "{" and cierre == "}"
end

function PrintParameter()

    local tabla = helpMet.split_lines(vInventory.description)
    local pop = false
    for i, v in pairs(tabla) do
        local tablanew = separarTexto(v)
        imgui.Spacing()
        
        if v == "" then
            imgui.MarginY(20)
        else
            local canText = 0
            for k, a in pairs(tablanew) do
                if a ~= "" then
                    if verificarLlaves(a) then
                        local color = imgui.ImColorHex(a)
                        imgui.PushStyleColor(imgui.Col.Text, color)
                        pop = true
                    else
                        canText = canText + 1
                        if canText > 1 then
                            imgui.MarginX(-7)
                        end

                        print(ffi.string(a))

                        imgui.Text(u8(ffi.string(a)))
                        imgui.SameLine()
                    end
                end
            end
        end

    end
    
    if pop then
        imgui.PopStyleColor()
    end
    
end

script.terminate = function() SaveData() end

function CargarCommandosGlobal()
    NewChatCommand("as", "Abre la ventana de configuracion.", vConfig.OpenOrCloseView);
    NewChatCommand("nm", "Crea nuevo macro.", CrearNuevoMacro);
    

    sampRegisterChatCommand("vall", buttonOpenViewAll );
    sampRegisterChatCommand("na", buttonNewAction );
    sampRegisterChatCommand("nsc", buttonNewSubCommand );
    sampRegisterChatCommand("carFind", buscarCarro)
end

function NewChatCommand(cmd, description, fun)
    sampRegisterChatCommand(cmd, fun, description, description);
    sampSetClientCommandDescription(cmd, description);
end

function crearVistaItemsMacros(macro, index)
    if imgui.CollapsingHeader(macro.name) then
        imgui.Text("Key Activate: ")
        imgui.Text("\t" .. vk.parse_array_keys_from_string(macro.keysActivate))
        imgui.Separator()
        imgui.Text("Commands:")
        imgui.Text("\t" .. helpMet.format_arrays(macro.commands))
        imgui.Separator()
        imgui.Text("Status:")
        imgui.Text("\t" .. helpMet.translate_movement_type(macro.status))
        imgui.Separator()
        imgui.Text("Timeout to activate next command :")
        imgui.Text("\t" .. macro.timeWaitCmds .. " ms")
        imgui.Separator()
        local checkbox = new.bool(macro.enable)
        if imgui.Checkbox("Enable macro", checkbox) then 
            macro.enable = checkbox[0]
            SaveData()
        end
        imgui.SameLine()
        if imgui.Button("Activar") then
            _ = lua_thread.create(function ()
                EjecutarCmd(macro)
            end)
        end
        imgui.SameLine()
        if imgui.Button("Editar") then
            EditarMacro(macro, index)
        end
        imgui.SameLine()
        if imgui.Button("Eliminar") then
           EliminarMacro(macro, index)
        end
        
    end
end

function crearVistaItemsAction(action, index)
    if imgui.CollapsingHeader(action.name) then
        imgui.Text("Text activate: ")
        imgui.TextWrapped("\t" .. action.textActive)
        imgui.Separator()
        imgui.Text("Commands:")
        imgui.Text("\t" .. helpMet.format_arrays(action.commands))
        imgui.Separator()
        imgui.Text("Timeout to activate next command :")
        imgui.Text("\t" .. action.timeWaitCmds .. " ms")
        imgui.Separator()
        imgui.Text("Auto active:")
        imgui.Text("\t" .. helpMet.format_bool(action.autoActivate))
        if not action.autoActivate then
            imgui.MarginY(10)
            imgui.Separator()
            imgui.Text("Text desactivate:")
            imgui.TextWrapped("\t" .. helpMet.format_arrays(action.textDesactive))
            imgui.Separator()
            imgui.Text("Timeout to auto desactivar accion :")
            imgui.Text("\t" .. action.timeWaitDesactivateAction .. " ms")
            imgui.Separator()
            imgui.Text("Key Activate: ")
            imgui.Text("\t" .. vk.parse_array_keys_from_string(action.keysActivate))
        end
        imgui.MarginY(10)
        imgui.Separator()
        imgui.MarginY(10)
        
        local checkbox = new.bool(action.enable)
        if imgui.Checkbox("Enable macro", checkbox) then 
            action.enable = checkbox[0]
            SaveData()
        end
        imgui.SameLine()
        if imgui.Button("Activar") then
            _ = lua_thread.create(function ()
                EjecutarCmd(action)
            end)
        end
        imgui.SameLine()
        if imgui.Button("Editar") then
            EditarAction(action, index)
        end
        imgui.SameLine()
        if imgui.Button("Eliminar") then
           EliminarAction(action, index)
        end
        
    end
end

function crearVistaItemsSubCommand(subcmd, index)
    if imgui.CollapsingHeader(subcmd.name) then
        imgui.Text("Command activate")
        imgui.Text("\t" .. subcmd.command)
        imgui.Text("Commands")
        imgui.Text("\t" .. helpMet.format_arrays(subcmd.commands))
        imgui.Separator()
        imgui.Text("Timeout to activate next command :")
        imgui.Text("\t" .. subcmd.timeWaitCmds .. " ms")
        imgui.Separator()
        imgui.MarginY(10)
        
        local checkbox = new.bool(subcmd.enable)
        if imgui.Checkbox("Enable macro", checkbox) then 
            subcmd.enable = checkbox[0]
            SaveData()
        end
        imgui.SameLine()
        if imgui.Button("Activar") then
            _ = lua_thread.create(function ()
                EjecutarCmd(subcmd)
            end)
        end
        imgui.SameLine()
        if imgui.Button("Editar") then
            EditarSubCommand(subcmd, index)
        end
        imgui.SameLine()
        if imgui.Button("Eliminar") then
            EliminarSubCommand(subcmd, index)
        end
        
    end
end

function EliminarMacro(macro, index)
    vPopup.Delete.index = index
    vPopup.Delete.visible[0] = true
    _ = lua_thread.create(function ()
        while vPopup.Delete.visible[0] do wait(50) end
        if vPopup.Delete.remove then
            table.remove(GLOBAL_DATA.list_macro, vPopup.Delete.index)
            SaveData()
        end
    end)
end

function EliminarAction(action, index)
    vPopup.Delete.index = index
    vPopup.Delete.visible[0] = true
    _ = lua_thread.create(function ()
        while vPopup.Delete.visible[0] do wait(50) end
        if vPopup.Delete.remove then
            table.remove(GLOBAL_DATA.list_acction, vPopup.Delete.index)
            SaveData();
        end
    end)
end

function EliminarSubCommand(subcmd, index)
    vPopup.Delete.index = index
    vPopup.Delete.visible[0] = true
    _ = lua_thread.create(function ()
        while vPopup.Delete.visible[0] do wait(50) end
        if vPopup.Delete.remove then
            table.remove(GLOBAL_DATA.list_subcommand, vPopup.Delete.index)
            SaveData();
        end
    end)
end

function EditarMacro(macro, index)
    vMacroCrud.visible[0] = true
    vMacroCrud.index = index
    vMacroCrud.name = "Editar Macro"
    

end

function EditarAction(action, index)
    vActionCrud.visible = new.bool(true)
    vActionCrud.name = "Editar Action"
    vActionCrud.index = index

    vActionCrud.buttonText = "Grabar KeyHot"
    vActionCrud.labelKeysActivate = vk.parse_array_keys_from_string(action.keysActivate)
    vActionCrud.grabando = false

    vActionCrud.inputNameAction = new.char[64](action.name)
    vActionCrud.inputTextActivate = new.char[255](action.textActive)
    vActionCrud.inputTextDesactivate = new.char[1024](helpMet.format_arrays(action.textDesactive))
    vActionCrud.inputCommands = new.char[1024](helpMet.format_arrays(action.commands))
    vActionCrud.timeWaitCmds = new.int(action.timeWaitCmds)
    vActionCrud.timeWaitDesactivateAction = new.int(action.timeWaitDesactivateAction)
    vActionCrud.autoActivate = new.bool(action.autoActivate)
    vActionCrud.keysActivate = action.keysActivate

end

function EditarSubCommand(subcmd, index)
    vSubCommandCrud.visible = new.bool(true)
    vSubCommandCrud.name = "Editar SubCommand"
    vSubCommandCrud.index = index

    vSubCommandCrud.inputName = new.char[64](subcmd.name)
    vSubCommandCrud.inputCommand = new.char[64](subcmd.command)
    vSubCommandCrud.inputCommands = new.char[1024](helpMet.format_arrays(subcmd.commands))
    vSubCommandCrud.timeWaitCmds = new.int(subcmd.timeWaitCmds)

end


function vConfig.buttonAllView()
    vAllviews.visible[0] = true
    vConfig.visible[0] = false
end

function vConfig.buttonNewMacro()
    vMacroCrud.NewMacro()
end

function vConfig.buttonNewAction()
    if vActionCrud.visible[0] ~= true then 
        vActionCrud.visible[0] = true 
        vActionCrud.name = "Nuevo Acction"
        limpiarViewAction()
    end
end

function vConfig.buttonNewSubCommand()
    if vSubCommandCrud.visible[0] ~= true then 
        vSubCommandCrud.visible[0] = true 
        vSubCommandCrud.name = "Nuevo SubCommand"
        limpiarViewSubCommand()
    end
end

function CrearNuevoMacro()
    lua_thread.create(function ()
        local nMacro = vMacroCrud.NewMacro()
        print(nMacro.name)
    end)
end



function limpiarViewAction()
    vActionCrud.keysActivate = {}
    vActionCrud.inputNameAction = new.char[64]()
    vActionCrud.inputTextActivate = new.char[255]()
    vActionCrud.inputTextDesactivate = new.char[255]()
    vActionCrud.inputCommands = new.char[1024]()
    vActionCrud.timeWaitCmds[0] = 1000
    vActionCrud.timeWaitDesactivateAction[0] = 5000
    vActionCrud.autoActivate = new.bool(true)
    vActionCrud.keysActivate = {}

    vActionCrud.labelKeysActivate = new.char[1024]()
    vActionCrud.index = 0
    
end

function limpiarViewSubCommand()
    vSubCommandCrud.inputName = new.char[64]()
    vSubCommandCrud.inputCommand = new.char[64]()
    vSubCommandCrud.inputCommands = new.char[1024]()
    vSubCommandCrud.timeWaitCmds = new.int(1000)

    vSubCommandCrud.index = 0
    vSubCommandCrud.name = ""
    
end

function buttonAceptarViewMacro()
    --Verificar datos completos
    if ffi.string(vMacroCrud.inputNameMacro) == ""
    or #vMacroCrud.keysActivate == 0 
    or vMacroCrud.inputTimeWaitCmd[0] < 0
    or ffi.string(vMacroCrud.inputCommands) == ""
    or vMacroCrud.grabando then
        vPopup.Error.visible[0] = true
        vPopup.Error.msg = "Faltan datos de completar."


    else
        
        --combierto datos a tabla
        local macro = {
            name = ffi.string(vMacroCrud.inputNameMacro),
            keysActivate = vMacroCrud.keysActivate,
            timeWaitCmds = vMacroCrud.inputTimeWaitCmd[0],
            commands = helpMet.split_lines(ffi.string(vMacroCrud.inputCommands)),
            status = vMacroCrud.status[0],
            enable = true
        }
        
        local arrg1, arrg2, arrg3 = verificar_keys_existed(macro.keysActivate)
        
        function addDatos()
            if (vMacroCrud.index == 0 ) then
                table.insert(GLOBAL_DATA.list_macro, macro)
                CreateMacro(macro)
            else
                GLOBAL_DATA.list_macro[vMacroCrud.index].name = macro.name
                GLOBAL_DATA.list_macro[vMacroCrud.index].keysActivate = macro.keysActivate
                GLOBAL_DATA.list_macro[vMacroCrud.index].timeWaitCmds = macro.timeWaitCmds
                GLOBAL_DATA.list_macro[vMacroCrud.index].commands = macro.commands
                GLOBAL_DATA.list_macro[vMacroCrud.index].status = macro.status
                GLOBAL_DATA.list_macro[vMacroCrud.index].enable = macro.enable
            end

            limpiarViewMacro()
            SaveData()
            vMacroCrud.visible[0] = false

        end

        --Este linea verifica que la combinacion de tecla esta repetida en algun otro macro,
        -- si es asi, mandara una ventana de confirmacion, para agregar el macro
        if arrg1 and arrg3 ~= vMacroCrud.index then
            vPopup.KeyRepetido.visible[0] = true
            vPopup.KeyRepetido.macro = arrg2
            vPopup.KeyRepetido.index = arrg3

            _ = lua_thread.create(
            function ()
                while vPopup.KeyRepetido.visible[0] do wait(50) end
                if vPopup.KeyRepetido.add then
                    addDatos()
                end
            end)

        else
            addDatos()
        end 
            
    end
end

function buttonCancelarViewMacro()
    limpiarViewMacro()

    vMacroCrud.visible[0] = false
end

function buttonAceptarViewAction()

    local acction = {
        enable = true,
        name = ffi.string(vActionCrud.inputNameAction),
        textActive = ffi.string(vActionCrud.inputTextActivate),
        textDesactive = helpMet.split_lines(ffi.string(vActionCrud.inputTextDesactivate)),
        commands = helpMet.split_lines(ffi.string(vActionCrud.inputCommands)),
        timeWaitCmds = vActionCrud.timeWaitCmds[0],
        timeWaitDesactivateAction = vActionCrud.timeWaitDesactivateAction[0],
        autoActivate = vActionCrud.autoActivate[0],
        keysActivate = vActionCrud.keysActivate,
    }

    --Verificar datos completos
    if acction.name == ""
    or acction.textActive == ""
    or #acction.commands == 0
    then
        vPopup.Error.visible[0] = true
        vPopup.Error.msg = "Faltan datos de completar."
    elseif not acction.autoActivate and #acction.keysActivate == 0 then 
        vPopup.Error.visible[0] = true
        vPopup.Error.msg = "La auto activacion esta desactivada.\nIngrese una tecla para activar."    
    else
        
        function addDatos()
            local index = vActionCrud.index
            if (index == 0 ) then
                table.insert(GLOBAL_DATA.list_acction, acction)
                -- Funcion para activar la accíon
                CreateAccion(acction);
            else
                GLOBAL_DATA.list_acction[index].enable = acction.enable
                GLOBAL_DATA.list_acction[index].name = acction.name
                GLOBAL_DATA.list_acction[index].textActive = acction.textActive
                GLOBAL_DATA.list_acction[index].textDesactive = acction.textDesactive
                GLOBAL_DATA.list_acction[index].commands = acction.commands
                GLOBAL_DATA.list_acction[index].timeWaitCmds = acction.timeWaitCmds
                GLOBAL_DATA.list_acction[index].timeWaitDesactivateAction = acction.timeWaitDesactivateAction
                GLOBAL_DATA.list_acction[index].autoActivate = acction.autoActivate
                GLOBAL_DATA.list_acction[index].keysActivate = acction.keysActivate
            end

            limpiarViewAction()
            SaveData()
            vActionCrud.visible[0] = false

        end

        addDatos()

    end 
end

function buttonAceptarSubCommand()

    local subCmd = {
        enable = true,
        name = ffi.string(vSubCommandCrud.inputName),
        command = ffi.string(vSubCommandCrud.inputCommand),
        commands = helpMet.split_lines(ffi.string(vSubCommandCrud.inputCommands)),
        timeWaitCmds = vSubCommandCrud.timeWaitCmds[0],
    }

    --Verificar datos completos
    if subCmd.name == ""
    or subCmd.command == ""
    or #subCmd.commands == 0
    then
        vPopup.Error.visible[0] = true
        vPopup.Error.msg = "Faltan datos de completar."
    elseif verificar_SubCommand_existed(subCmd, vSubCommandCrud.index) then
        vPopup.Error.visible[0] = true
        vPopup.Error.msg = "El commando ya esta registrado. Uso otro" 
    else
        
        function addDatos()
            local index = vSubCommandCrud.index
            if (index == 0 ) then
                table.insert(GLOBAL_DATA.list_subcommand, subCmd)
            else
                sampUnregisterChatCommand(GLOBAL_DATA.list_subcommand[index].command)
                GLOBAL_DATA.list_subcommand[index].enable = subCmd.enable
                GLOBAL_DATA.list_subcommand[index].name = subCmd.name
                GLOBAL_DATA.list_subcommand[index].command = subCmd.command
                GLOBAL_DATA.list_subcommand[index].commands = subCmd.commands
            end
            
            -- Funcion para activar sub-command
            CrearSubCommand(subCmd);

            limpiarViewSubCommand()
            SaveData()
            vSubCommandCrud.visible[0] = false

        end

        addDatos()

    end 
end

function buttonCancelarViewAction()
    limpiarViewMacro()
    
    vActionCrud.visible[0] = false
end

function buttonCancelarSubCommand()
    limpiarViewSubCommand()
    
    vSubCommandCrud.visible[0] = false
end

function verificar_SubCommand_existed(subCommand, index)
    for k, v in ipairs(GLOBAL_DATA.list_subcommand) do
        if v.command == subCommand.command and index ~= k then
            return true
        end
    end
    return false
end

function verificar_keys_existed(keysComparter)
    for index, macro in pairs(GLOBAL_DATA.list_macro) do
        local esIgual = false
        for i, tecla in ipairs(macro.keysActivate) do
            if keysComparter[i] ~= nil then
                if tecla.value ==  keysComparter[i].value then
                    esIgual = true
                end
            end
        end
        if esIgual then 
            return esIgual, macro, index
        end
    end
    return false, nil, nil
end

function CargarAction()
    if GLOBAL_DATA.list_acction == nil then
        GLOBAL_DATA.list_acction = {}
    end

    local acciones = GLOBAL_DATA.list_acction
    for _, accion in ipairs(acciones) do
        CreateAccion(accion)
    end
    sendConsoleMessageSamp("Se cargaron " .. #acciones .. " acciones.")

end

function CreateAccion(accion)
    _ = lua_thread.create(
        function()
            while true do
                wait(accion.timeWaitCmds)
                local msgConcide = EsperarMensaje(accion.textActive)
                ActivarAccion(accion)
            end
        end
    )
end

function ActivarAccion(accion)
    if accion.enable and vConfig.accionesOn[0] then
        if accion.autoActivate then
            EjecutarCmd(accion)
        else
            local mensaje = "Presiona " .. vk.parse_array_keys_from_string(accion.keysActivate) .. " para " .. accion.name
            printString(mensaje, accion.timeWaitDesactivateAction)
            local msgDesactive = false;
            if #accion.textDesactive == 0 then
                for i, item in ipairs(accion.textDesactive) do
                    _ = lua_thread.create(
                        function() 
                            msgDesactive = EsperarMensaje(item)
                        end
                    )
                end
            end

            local tiempoInicio = os.clock()
            local duraxMax = accion.timeWaitDesactivateAction / 1000
            while (os.clock() - tiempoInicio) <  duraxMax and not msgDesactive do
                wait(10)
                if vk.is_key_pressed(accion.keysActivate) then
                    EjecutarCmd(accion)
                    break
                end
            end
            clearPrints()
        end
    end
end

function CargarMacros()

    if GLOBAL_DATA.list_macro == nil then
        GLOBAL_DATA.list_macro = {}
    end

    local macros = GLOBAL_DATA.list_macro

    for _, macro in ipairs(macros) do
        CreateMacro(macro)
    end
    sendConsoleMessageSamp("Se cargaron " .. #macros .. " macros.")

end

function CargarSubCommand()

    if GLOBAL_DATA.list_subcommand == nil then
        GLOBAL_DATA.list_subcommand = {}
    end

    local subcmds = GLOBAL_DATA.list_subcommand

    for _, subcmd in ipairs(subcmds) do
        CrearSubCommand(subcmd)
    end
    sendConsoleMessageSamp("Se cargaron " .. #subcmds .. " sub-commands.")

end

function CreateMacro(macro)
    _ = lua_thread.create(function()
        
        while true do
            
            local comboPressed = vk.get_hotkey_pressed(macro.keysActivate)
            
            local estado = isCharInAnyCar(PLAYER_PED)
            
            if comboPressed  and GLOBAL_DATA.settings.macrosOn and macro.enable and not vMacroCrud.IsVisible() then
                
                if macro.status == 0 then
                    EjecutarCmd(macro)
                elseif macro.status == 1 and estado then
                    EjecutarCmd(macro)
                elseif macro.status == 2 and not estado then  
                    EjecutarCmd(macro)
                end
                
            end
            wait(macro.timeWaitCmds)
        end
    end)
end

function CrearSubCommand(subcommad)
    sampRegisterChatCommand(subcommad.command, 
        function()
            if subcommad.enable and vConfig.subComandosOn[0] then
                lua_thread.create(
                    function()
                        EjecutarCmd(subcommad, true)
                    end
                )
            end
        end
    )
end



function sendConsoleMessageSamp(msg)
    local index = string.format("{FFFFFF}[ {1FDADC}%s {FFFFFF}]: ", thisScript().name)
    sampAddChatMessage(index .. msg, 0xD6DADC)
end

function EsperarMensaje(msg)
    local msgNew, msgOld = {}
    msg = cleanAndLower(msg)
    while true do
        wait(50)

        msgNew, msgOld = GetMessageNew(msgOld)

        if #msgNew > 0 then
            for index, textMsg in ipairs(msgNew) do
                local text1 = cleanAndLower(textMsg)
                if text1 == msg then
                    return true
                end
            end
        end

    end

end

function GetMessageNew(messagesOld)

    if messagesOld == nil then messagesOld = {} end

    local lengLineChat = 10
    local chatNew = {}

    local chatText = {}

    for i = 1, lengLineChat do
        local text = sampGetChatString(100 - i)
        table.insert(chatText, cleanAndLower(text))
    end
    
    if #messagesOld == 0 then
        return chatNew, chatText
    else

        chatNew = {}
        local count = 1
        for i = 1 , lengLineChat do

            local chat1 = chatText[i]
            local chat2 = messagesOld[count]
            
            if(not (chat1 == chat2)) then
                table.insert(chatNew, chat1)
            else
                count = count + 1
            end
          
        end

        return chatNew, chatText
        
        
    end
    
end

function cleanAndLower(text)
    -- Elimina códigos de color y otros caracteres no alfanuméricos
    local cleanedText = text:gsub('{.-}', ''):gsub('[^%w ]', '')

    -- Convierte el texto a minúsculas
    cleanedText = string.lower(cleanedText)

    return cleanedText
end

function SaveData()
    helpMet.SaveDataJson(URL, GLOBAL_DATA)
    print("Finished saving")
end

return model