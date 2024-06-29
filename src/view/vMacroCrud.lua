local modulo = {}

local imgui = require 'src/imple/mimgui'
local vk = require 'src/imple/keysC'
local ffi = require 'ffi'
local new = imgui.new
local X, Y = getScreenResolution()


local visible = new.bool(false)
local name = ""
local index = 0

local MacroInteraction = nil
local OperationComplete = false

local buttonText = "Grabar KeyHot"
local grabando = false
local labelKeysActivate = ""
 
local inputNameMacro = new.char[64]()
local keysActivate = {}
local inputTimeWaitCmd = new.int(1000)
local inputCommands = new.char[1024]()
local status = new.int(0)
 
local vPopup = {}
local PoputErrorVisible = new.bool(false)
local PoputErrorMsg = ""
 
local PoputAdvertenciaVisible = new.bool(false)
local PoputAdvertenciaTitle = ""
local PoputAdvertenciaMsg = ""
local PoputAdvertenciaResult = nil

modulo.buttonAceptarViewMacro = nil
modulo.buttonCancelarViewMacro = nil

local thread_GrabarKey = lua_thread.create_suspended(
        function() 
            grabando = true
            keysActivate = {}

            while (grabando) do 
                local key = vk.get_key_pressed()
                local insert = true

                if(key ~= nil and not helpMet.existe_en_lista(keysActivate, key)) then
                    
                    if(key.category ~= vk.categorys.KeyAccion) then 
                        grabando = false 
                    end
                    
                    if(key.category == vk.categorys.KeyAccion and #keysActivate >= 2) then 
                        grabando = true
                        insert = false
                    end
                    
                    if(insert) then 
                        table.insert(keysActivate, key)
                    end
                end
            end
        end
)



imgui.OnFrame( function() return visible[0] end, 
    function()
        imgui.SetNextWindowSize(imgui.ImVec2(194, 120), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(X / 2, Y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        
        imgui.Begin("##Macro", visible, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize)
        
        imgui.InputText('Name', inputNameMacro, 128)
        
        if grabando then
            buttonText = "Detener Grabacion"
        else
            buttonText = "Grabar KeyHot"
        end

        labelKeysActivate = vk.parse_array_keys_from_string(keysActivate)

        if imgui.Button(buttonText) then 
            
            if not grabando then
                thread_GrabarKey:run()
            else
                if thread_GrabarKey ~= nil then
                    thread_GrabarKey:terminate(thread_GrabarKey)
                end
                keysActivate = {}
                grabando = false
            end
        end imgui.SameLine()
        imgui.Text(labelKeysActivate)
        
        imgui.InputInt("Time between commands ms", inputTimeWaitCmd, 1000, 1000)
        imgui.InputTextMultiline("Commands", inputCommands, 0x400,  imgui.ImVec2(0, 100))
        imgui.Separator()
        imgui.Text("Estado de activicion del macro")
        imgui.RadioButtonIntPtr("All", status, 0) imgui.SameLine()
        imgui.RadioButtonIntPtr("In Car", status, 1) imgui.SameLine()
        imgui.RadioButtonIntPtr("Walking", status, 2) 
        imgui.MarginY(10)
        imgui.Separator()
        imgui.MarginY(10)
        imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize('Crear Macro').x - imgui.CalcTextSize('Cancelar').x)/2.2)
        imgui.MarginY(10)
        if imgui.Button("Aceptar") then
            if not grabando then
                MacroInteraction = validarDatos()
                if MacroInteraction ~= nil then
                    OperationComplete = true
                    visible[0] = false
                end
            end
        end
        imgui.SameLine()
        if imgui.Button("Cancelar") then
            if not grabando then
                OperationComplete = true
                MacroInteraction = nil
                visible[0] = false
            end
        end

        imgui.PoputError(PoputErrorMsg, PoputErrorVisible) -- Implementa la vista de error
        imgui.PoputAdvertencia(PoputAdvertenciaTitle, PoputAdvertenciaMsg, PoputAdvertenciaVisible, PoputAdvertenciaResult) -- Implementa la vista de advertencia
        
        imgui.End()
    end
)

function limpiarView()
    inputNameMacro = new.char[64]()
    keysActivate = {}
    inputTimeWaitCmd[0] = 1000
    inputCommands = new.char[1024]()
    status[0] = 0
    labelKeysActivate = new.char[1024]()
    index = 0
    
end

function modulo.NewMacro()
    
    if visible[0] then return end

    OperationComplete = false
    visible[0] = true
    name = "Nuevo Macro"
    limpiarView()

    while not OperationComplete do
        wait(50)
    end

    return MacroInteraction
end

function modulo.EditMacro(macro)
    if visible[0] then return end

    OperationComplete = false
    
    visible[0] = true
    name = "Editar Macro"
    labelKeysActivate = vk.parse_array_keys_from_string(macro.keysActivate)
    inputNameMacro = new.char[64](macro.name)
    inputTimeWaitCmd[0] = macro.timeWaitCmds
    keysActivate = macro.keysActivate
    inputCommands = new.char[1024](helpMet.format_arrays(macro.commands))
    status[0] = macro.status

    while not OperationComplete do
        wait(50)
    end

    return MacroInteraction
end

function modulo.IsVisible()
    return visible[0]
end

function vPopup.Error(msg)
    PoputErrorMsg = msg
    PoputErrorVisible[0] = true
end

function vPopup.Advertencia(title, msg)
    PoputAdvertenciaTitle = title
    PoputAdvertenciaMsg = msg
    PoputAdvertenciaVisible[0] = true
    while true do
        wait(50)
        if PoputAdvertenciaResult ~= nil then
           return PoputAdvertenciaResult 
        end
    end
end

function validarDatos()

    local macro = {
        name = ffi.string(inputNameMacro),
        keysActivate = keysActivate,
        timeWaitCmds = inputTimeWaitCmd[0],
        commands = helpMet.split_lines(ffi.string(inputCommands)),
        status = status[0],
        enable = true
    }

    --Verificar datos completos
    
    if macro.name == ""
    or #macro.keysActivate == 0 
    or macro.timeWaitCmds < 0
    or #macro.commands == 0
    then
        vPopup.Error("Faltan datos de completar.")
    else

        local verif, name = is_keys_register(macro.keysActivate)

        if verif then
            local add = vPopup.Advertencia("Este hotkey ya esta registrado.", name)
            if add then 
                return macro
            end
        else
            return macro
        end
            
    end

    return nil

end

function is_keys_register(keys)
    local keysName = ""

    for _, keyhot in pairs(HOTKEY_USADOS) do
        if keyhot.keys == keys then
            keysName = keysName .. keyhot.type .. " : " .. keyhot.Name .. ".\n"
        end
    end
    

end


return modulo