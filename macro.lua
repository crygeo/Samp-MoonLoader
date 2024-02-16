script_name('MacroDef')
script_version('0.0.1')
script_author('CryGeo')
script_description('Puedes crear macros de muchos formas.')

local dkjson = require("lib/dkjson-master/dkjson")
local moonloader = require("moonloader")

local imgui = require 'mimgui'
local new = imgui.new


local vk = require 'keysC'
local event = require('moonloader').event


local URL = "config/macrosDef.json"
local config = nil
local settings = nil

--Views
local viewCreateMacro =  new.bool(true)
local viewCreateEvento =  new.bool(false)
local viewCreateSubComando =  new.bool(false)
local settingView = new.bool(false)



local menu_keys = {
    VK_CONTROL,
    VK_RCONTROL,
    VK_LSHIFT,
    VK_RSHIFT,
    VK_LMENU,
    VK_RMENU,
    VK_MENU,
    VK_SHIFT,
}
-- Tabla con todas las letras
local letras = {
    VK_A, VK_B, VK_C, VK_D, VK_E, VK_F, VK_G, VK_H, VK_I, VK_J, VK_K, VK_L,
    VK_M, VK_N, VK_O, VK_P, VK_Q, VK_R, VK_S, VK_T, VK_U, VK_V, VK_W, VK_X, VK_Y, VK_Z
}

-- Tabla con todos los números
local numeros = {
    VK_0, VK_1, VK_2, VK_3, VK_4, VK_5, VK_6, VK_7, VK_8, VK_9
}

-- Tabla con el teclado numérico
local tecladoNumerico = {
    VK_NUMPAD0, VK_NUMPAD1, VK_NUMPAD2, VK_NUMPAD3, VK_NUMPAD4,
    VK_NUMPAD5, VK_NUMPAD6, VK_NUMPAD7, VK_NUMPAD8, VK_NUMPAD9
}

local keyIgnore = {
    0x20,
    0x5B
}

local X, Y = getScreenResolution()
function main()

    wait(1000)
    sendConsoleMessageSamp(string.format(" Script created by %s", "CryGeo"))

    config = getInfor(URL)


    if config then
        local macros = config.Macros
        local acciones = config.Accions
        local subComandos = config.SubComandos

        settings = config.Settings
        
        settings.macrosOn = new.bool(settings.macrosOn)
        settings.acctionOn = new.bool(settings.acctionOn)
        settings.subComandosOn = new.bool(settings.subComandosOn)

        ViewSettings(settings)
        CrearMacroView()

        CargarCommandosConfig(settings)
        CargarMacros(macros)
        CargarAcciones(acciones)
        CargarSubComandos(subComandos)


    end
    
    wait(-1)
end

function ViewSettings(settings)
    imgui.OnFrame(function() return settingView[0] end,
    function()
        imgui.SetNextWindowSize(imgui.ImVec2(194, 120), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(X / 2, Y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

        imgui.Begin("Settings", settingView, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize)
    
        
        imgui.Text("Configuracion del procesos.") -- Display some text (you can use a format strings too)
        imgui.Checkbox("Macros On", settings.macrosOn) -- Edit bools storing our window open/close state
        imgui.Checkbox("Acction On", settings.acctionOn)
        imgui.Checkbox("SubCommandos On", settings.subComandosOn)
        imgui.Separator()
        if  imgui.Button("Crear Macro") then  CrearMacroView() end
        imgui.SameLine()        
        if  imgui.Button("Crear Evento")  then  printString("Provando Macro", 3000) end
        imgui.SameLine()        
        if  imgui.Button("Crear Sub Cmd") then  printString("Provando Macro", 3000) end
        imgui.SameLine()        
       
    
        imgui.End()
        
        
    end)
    
end

function CrearMacroView()

    local text = imgui.new.char[50]()
    local keysPress = {}
    local grabando = false
    local textButton = "Grabar Macro"
    local keyText = ""
    local thread = lua_thread.create_suspended(
        function() 
            grabando = true
            textButton = "Detener Grabacion"
            keysPress = {}

            while (grabando) do 
                local keyPress = vk.get_key_pressed()
                print(keyPress.category)
                print(keyPress.name)
                
                table.insert(keysPress, keyPress)
            end
        end
    )


    if (settingView[0] == true) then settingView[0] = false end
    viewCreateMacro[0] = true;

    imgui.OnFrame(function() return viewCreateMacro[0] end, 
    function ()
        imgui.SetNextWindowPos(imgui.ImVec2(X / 2, Y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(194, 120), imgui.Cond.FirstUseEver)
        imgui.Begin("New Macro", viewCreateMacro, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize )
        imgui.InputText("Name", text, 30)
        if imgui.Button(textButton) then 

            if not grabando then
                thread:run()
            else
                if thread ~= nil then
                    thread:terminate(thread)
                end
                textButton = "Grabar Macro"
                grabando = false
            end
        end 
        imgui.SameLine()
        imgui.Text(keyText )
        end)

end





function obtenerNombreTeclas(teclas)
    local teclasMenuAtras, teclasTecladoAdelante = ordenarTeclas(teclas)
    local nombreTeclas = ""

    -- Obtener nombres de teclas de menú hacia atrás
    for i, tecla in ipairs(teclasMenuAtras) do
        nombreTeclas = nombreTeclas .. nombreTecla(tecla)
        if i < #teclasMenuAtras then
            nombreTeclas = nombreTeclas .. " + "
        end
    end

    -- Agregar separador si hay teclas de ambos grupos
    if #teclasMenuAtras > 0 and #teclasTecladoAdelante > 0 then
        nombreTeclas = nombreTeclas .. " + "
    end

    -- Obtener nombres de teclas de teclado hacia adelante
    for i, tecla in ipairs(teclasTecladoAdelante) do
        nombreTeclas = nombreTeclas .. nombreTecla(tecla)
        if i < #teclasTecladoAdelante then
            nombreTeclas = nombreTeclas .. " + "
        end
    end

    return nombreTeclas
end

function nombreTecla(tecla)
    local nombreTeclas = {
        [VK_LMENU] = "ALT",
        [VK_RMENU] = "ALT",
        [VK_MENU] = "ALT",
        [VK_LCONTROL] = "CTRL",
        [VK_RCONTROL] = "CTRL",
        [VK_CONTROL] = "CTRL",
        [VK_LSHIFT] = "SHIFT",
        [VK_RSHIFT] = "SHIFT",
        [VK_SHIFT] = "SHIFT",
        [VK_0] = "0",
        [VK_1] = "1",
        [VK_2] = "2",
        [VK_3] = "3",
        [VK_4] = "4",
        [VK_5] = "5",
        [VK_6] = "6",
        [VK_7] = "7",
        [VK_8] = "8",
        [VK_9] = "9",
        [VK_NUMPAD0] = "NUM 0",
        [VK_NUMPAD1] = "NUM 1",
        [VK_NUMPAD2] = "NUM 2",
        [VK_NUMPAD3] = "NUM 3",
        [VK_NUMPAD4] = "NUM 4",
        [VK_NUMPAD5] = "NUM 5",
        [VK_NUMPAD6] = "NUM 6",
        [VK_NUMPAD7] = "NUM 7",
        [VK_NUMPAD8] = "NUM 8",
        [VK_NUMPAD9] = "NUM 9",
        [string.byte("A")] = "A",
        [string.byte("B")] = "B",
        [string.byte("C")] = "C",
        [string.byte("D")] = "D",
        [string.byte("E")] = "E",
        [string.byte("F")] = "F",
        [string.byte("G")] = "G",
        [string.byte("H")] = "H",
        [string.byte("I")] = "I",
        [string.byte("J")] = "J",
        [string.byte("K")] = "K",
        [string.byte("L")] = "L",
        [string.byte("M")] = "M",
        [string.byte("N")] = "N",
        [string.byte("O")] = "O",
        [string.byte("P")] = "P",
        [string.byte("Q")] = "Q",
        [string.byte("R")] = "R",
        [string.byte("S")] = "S",
        [string.byte("T")] = "T",
        [string.byte("U")] = "U",
        [string.byte("V")] = "V",
        [string.byte("W")] = "W",
        [string.byte("X")] = "X",
        [string.byte("Y")] = "Y",
        [string.byte("Z")] = "Z",
    }

    return nombreTeclas[tecla] or string.char(tecla)
end


function tieneDosLetrasNumeros(tabla)
    
    local countLetras = contarElementos(tabla, letras)
    local countNumeros = contarElementos(tabla, numeros)
    local countNumerosTec = contarElementos(tabla, tecladoNumerico)
    
    return countLetras >= 2 or countNumeros >= 2 or countNumerosTec >= 2
end

function tieneDosMenu(tabla)
    
    local countMenu = contarElementos(tabla, menu_keys)
    
    return countMenu >= 2
end

function verificarCombinacion(tabla, key)
    

    local letra = valorExiste(letras, key) or valorExiste(numeros, key) or valorExiste(tecladoNumerico, key)
    local menu = valorExiste(menu_keys, key)

    local numLetras = contarElementos(tabla, letras) + contarElementos(tabla, numeros) + contarElementos(tabla, tecladoNumerico)
    local numMenu = contarElementos(tabla, menu_keys)

    return (not letra or numLetras < 2) and (not menu or numMenu < 1)
end

function ordenarTeclas(teclas)
    local teclasTecladoAdelante = {}
    local teclasMenuAtrasOrdenadas = {}
    
    for _, tecla in ipairs(teclas) do
        if valorExiste(menu_keys, tecla) then
            table.insert(menu_keys, tecla)
        else
            table.insert(teclasTecladoAdelante, tecla)
        end
    end

    table.sort(teclasTecladoAdelante)
    table.sort(teclasMenuAtrasOrdenadas)

    return teclasMenuAtrasOrdenadas, teclasTecladoAdelante
end

function valorExiste(tabla, valor)
    for _, v in ipairs(tabla) do
        if v == valor then
            return true
        end
    end
    return false
end

function contarElementos(tabla, elementos)
    local count = 0
    for _, v in ipairs(tabla) do
        if valorExiste(elementos, v) then
            count = count + 1
        end
    end
    return count
end

function CargarCommandosConfig(settings)
    sampRegisterChatCommand("md", function() settingView[0] = not settingView[0] end );
end

function CargarSubComandos(subComandos)
    for _, command in pairs(subComandos) do
        sampRegisterChatCommand(command.cmdInvoque, 
        function() 
            if not settings.subComandosOn[0] then return end
            EjecutarCmd(command.cmds, command.timeWaitCmds, true) 
        end)
    end

end

function CargarAcciones(accions)

    for _, accion in pairs(accions) do
        lua_thread.create(function() CreateAccion(accion) end)
    end
    
end

function CreateAccion(accion)
    local messageOld = {}

    while true do
        wait(50)

        local resultado = GetMessageNew(messageOld)

        local mensajeNew = resultado[1]
        messageOld = resultado[2]
        
        for _, message in pairs(mensajeNew) do
            if cleanAndLower(accion.text) == message then
                ActivarAccion(accion)
            end 
        end

    end 
end


function sendConsoleMessageSamp(msg)
    local index = string.format("{FFFFFF}[ {1FDADC}%s {FFFFFF}]: ", thisScript().name)
    sampAddChatMessage(index .. msg, 0xD6DADC)
end

function getInfor(url)
    local archivo = io.open( GetUrlThis(url), "r")

    if archivo then
        local contenido = archivo:read("*all")
        archivo:close()

        local success, datos = pcall(dkjson.decode, contenido)

        if success then
            return datos
        else
            print("Error al decodificar el archivo JSON:", datos)
        end
    else
        print("Error al abrir el archivo JSON")
    end
end

function GetUrlThis(url)
    return getWorkingDirectory() .. "/" .. url
end 

function CargarMacros(macros)
    sendConsoleMessageSamp("Cargando Macros...")
    for _, macro in ipairs(macros) do
        lua_thread.create( function() CreateMacro(macro) end)
    end
    sendConsoleMessageSamp("Se cargaron " .. #macros .. " macros.")

end

function CreateMacro(macro)
    while true do
        
        wait(20)
        
        local comboPressed = ObtenerCombinacionTecla(macro.keys)

        local estado = isCharInAnyCar(PLAYER_PED)

        if comboPressed  and settings.macrosOn[0]  then

            if macro.inCar == nil then
                EjecutarCmd(macro.cmds, macro.timeWaitCmds)
            elseif macro.inCar and estado then
                EjecutarCmd(macro.cmds, macro.timeWaitCmds)
            elseif not macro.inCar and not estado then  
                EjecutarCmd(macro.cmds, macro.timeWaitCmds)
            end
            
        end
    end
end

function ObtenerCombinacionTecla(keys)
    local longitud  = #keys

    if(longitud == 1) then
        local notKeyPressed = keyNotCombinable(config.keyIgnoreCombinations)
        if notKeyPressed then
            return wasKeyPressed(keys[1])
        end
    end

    local resultado = {}
    
    if(longitud > 1) then
        for i = 1, longitud do

            local keyPress = false
            if i == longitud then
                keyPress = wasKeyPressed(keys[i])
            
            else
                keyPress = isKeyDown(keys[i])
            end

            if keyPress == true then
                table.insert(resultado, keyPress)
            end

        end
        
    end

    if(longitud == #resultado) then
        return todosSonVerdaderos(resultado)
    end

    return false
    
end

function todosSonVerdaderos(array)
    for _, valor in ipairs(array) do
        if not valor then
            return false  -- Si se encuentra un valor falso, devuelve false
        end
    end
    return true  -- Si no se encontraron valores falsos, devuelve true
end

--[[
    Este metodo/funcion debuelve true si ninguna de la teclas de la lista keys esta precionada.
    Caso contrario dara false.
    {"name": "Alt", "value": 160},
]]
function keyNotCombinable(keys)
    local teclaNotRelation = false
    local keyNotPress = true

    for a, key in ipairs(keys) do
        if isKeyDown(key.value) then
            return false
        end
    end

    return true
end

function GetMessageNew(messagesOld)

    local lengLineChat = 10
    local chatNew = {}

    local chatText = {}

    for i = 1, lengLineChat do
        local text = sampGetChatString(100 - i)
        table.insert(chatText, cleanAndLower(text))
    end
    
    if #messagesOld == 0 then
        return {chatNew, chatText} 
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

        return {chatNew, chatText}
        
        
    end
    
end

function ActivarAccion(accion)

    if not settings.acctionOn[0] then return end 

    if(accion.autoActivate) then
        
        EjecutarCmd(accion.cmds, accion.timeWaitCmds)
        
    else

        local mensaje = "Presiona " .. accion.keyName .. " para " .. accion.name
        printString(mensaje, accion.timeWaitActive)

        local tiempoInicio = os.clock()
        local duracionMaxima = accion.timeWaitActive/1000  -- Duración máxima en segundos
        local completo = false

        while (os.clock() - tiempoInicio) < duracionMaxima and not completo do
            wait(20)
            local keyPress = wasKeyPressed(accion.keyActive)
            if keyPress then
                EjecutarCmd(accion.cmds, accion.timeWaitCmds)
                completo = true
                clearPrints()
            end
        end
    end
    
end

function cleanAndLower(text)
    -- Elimina códigos de color y otros caracteres no alfanuméricos
    local cleanedText = text:gsub('{.-}', ''):gsub('[^%w ]', '')

    -- Convierte el texto a minúsculas
    cleanedText = string.lower(cleanedText)

    return cleanedText
end

function invertirLista(lista)
    local listaInvertida = {}
    local longitud = #lista

    for i = longitud, 1, -1 do
        table.insert(listaInvertida, lista[i])
    end

    return listaInvertida
end

function EjecutarCmd(cmds, time, consoleCmd)

    local chatActive = sampIsChatInputActive()
    
    if chatActive and not consoleCmd then return end

    for i, cmd in ipairs(cmds) do
        sampSendChat(cmd)

        if( i < #cmds) then
            wait(time)
        end
    end
end



