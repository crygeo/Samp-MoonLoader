script_name('Asistente Samp')
script_version('0.0.1')
script_author('CryGeo')
script_description('Puedes crear macros/acciones/funcione de muchos formas.')

local dkjson = require("lib/dkjson-master/dkjson")

local imgui = require 'mimgui'
local new = imgui.new
local helpMet = require 'HelpMet'
local ffi = require 'ffi'
local vk = require 'keysC'

local URL = "config/macrosDef.json"
local X, Y = getScreenResolution()

local vConfig = {
    visible = new.bool(false),
}

local vAllviews = {
    visible = new.bool(false),
}

local vCrearMacro = {
    visible = new.bool(false),
    name = "",
    index = 0,

    buttonText = "Grabar KeyHot",
    grabando = false,
    labelText = "",
    
    inputNameMacro = new.char[64](),
    keysPress = {},
    inputTimeWaitCmd = new.int(1000),
    inputCommands = new.char[1024](),
    status = new.int(0),

}

local vPopup = {
    Error = { 
        visible = new.bool(false)
    },
    Delete = {
        visible = new.bool(false),
    },
    KeyRepetido = {
        visible = new.bool(false),
    }
}

local global_data = {}


local thread_GrabarKey = lua_thread.create_suspended(
        function() 

            vCrearMacro.buttonText = "Detener Grabacion"
            vCrearMacro.grabando = true
            vCrearMacro.keysPress = {}
            vCrearMacro.labelText = ""

            while (vCrearMacro.grabando) do 
                local key = vk.get_key_pressed()
                local insert = true

                if(key ~= nil and not helpMet.existe_en_lista(vCrearMacro.keysPress, key)) then
                    
                    if(key.category ~= vk.categorys.KeyAccion) then 
                        vCrearMacro.grabando = false 
                        vCrearMacro.buttonText = "Grabar KeyHot"
                    end
                    
                    if(key.category == vk.categorys.KeyAccion and #vCrearMacro.keysPress >= 2) then 
                        vCrearMacro.grabando = true
                        insert = false
                    end
                    
                    if(insert) then 
                        table.insert(vCrearMacro.keysPress, key)
                        if(vCrearMacro.keysPress ~= nil) then
                            vCrearMacro.labelText = vk.parse_array_keys_from_string(vCrearMacro.keysPress)
                        end
                    end
                end
            end
        end
)

function main()
    --cargar datos del json
    global_data = helpMet.GetDataArchivo(URL)

    if global_data == nil then
        global_data = {}
        global_data.settings = {
            macrosOn = true,
            acctionOn = true,
            subComandosOn = true,
        }
    end
    
    vConfig.macrosOn = new.bool(global_data.settings.macrosOn)
    vConfig.accionesOn = new.bool(global_data.settings.acctionOn)
    vConfig.subComandosOn = new.bool(global_data.settings.subComandosOn)

    while not isSampAvailable() do wait(50) end
    CargarCommandosGlobal()
    CargarMacros()
end




imgui.OnFrame( function() return vConfig.visible[0] end,
    function()
        imgui.SetNextWindowSize(imgui.ImVec2(194, 120), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(X / 2, Y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        
        imgui.Begin("Configuracion", vConfig.visible, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize)
        imgui.Text("Configuracion del procesos.")
        imgui.Checkbox("Macros On", vConfig.macrosOn)
        imgui.Checkbox("Acction On", vConfig.accionesOn)
        imgui.Checkbox("SubCommandos On", vConfig.subComandosOn)
        imgui.Separator()
        if imgui.Button("Crear Macro") then newMacro() end
        if imgui.Button("Ver All") then buttonAllView() end
        imgui.End()
    end
)

imgui.OnFrame( function() return vCrearMacro.visible[0] end, 
    function()
        imgui.SetNextWindowSize(imgui.ImVec2(194, 120), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(X / 2, Y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        
        imgui.Begin(vCrearMacro.name, vCrearMacro.visible, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize)
        
        imgui.InputText('Name', vCrearMacro.inputNameMacro, 128)
        if imgui.Button(vCrearMacro.buttonText) then 
            
            if not vCrearMacro.grabando then
                thread_GrabarKey:run()
            else
                if thread_GrabarKey ~= nil then
                    thread_GrabarKey:terminate(thread_GrabarKey)
                end
                vCrearMacro.labelText = ""
                vCrearMacro.keysPress = {}
                vCrearMacro.buttonText = "Grabar KeyHot"
                vCrearMacro.grabando = false
            end
        end imgui.SameLine()
        imgui.Text(vCrearMacro.labelText)
        imgui.InputInt("Time between commands ms", vCrearMacro.inputTimeWaitCmd, 1000, 1000)
        imgui.InputTextMultiline("Commands", vCrearMacro.inputCommands, 0x400,  imgui.ImVec2(0, 100))
        imgui.Separator()
        imgui.Text("Estado de activicion del macro")
        imgui.RadioButtonIntPtr("All", vCrearMacro.status, 0) imgui.SameLine()
        imgui.RadioButtonIntPtr("In Car", vCrearMacro.status, 1) imgui.SameLine()
        imgui.RadioButtonIntPtr("Walking", vCrearMacro.status, 2) 
        imgui.SetCursorPosY(275)
        imgui.Separator()
        imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize('Crear Macro').x - imgui.CalcTextSize('Cancelar').x)/2.2)
        imgui.SetCursorPosY(290)
        if imgui.Button("Aceptar") then
            buttonAceptarViewMacro()
        end
        imgui.SameLine()
        if imgui.Button("Cancelar") then
            buttonCancelarViewMacro()
        end

        if vPopup.Error.visible[0] then
            imgui.OpenPopup("Error")
        end
        if imgui.BeginPopupModal("Error", _, imgui.WindowFlags.NoResize) then
            imgui.SetWindowSizeVec2(imgui.ImVec2(250, 100))
            imgui.TextWrapped('Faltan datos de completar.')
            imgui.SetCursorPosY(55)
            imgui.Separator()
            imgui.SetCursorPosY(65)
            if imgui.Button("Aceptar", imgui.ImVec2(280, 24)) then
                vPopup.Error.visible[0] = false
                imgui.CloseCurrentPopup()
            end
        end
        if vPopup.KeyRepetido.visible[0] then
            imgui.OpenPopup("HotKeyRepetido")
        end
        if imgui.BeginPopupModal("HotKeyRepetido", _, imgui.WindowFlags.NoResize) then
            imgui.SetWindowSizeVec2(imgui.ImVec2(250, 100)) 
            imgui.TextWrapped('La combinacion es igual al macro:')
            imgui.Text(vPopup.KeyRepetido.macro.name)
            imgui.TextWrapped('Aun desea agregar el macro?')
            imgui.SetCursorPosY(55)
            imgui.Separator()
            imgui.SetCursorPosY(65)
            if imgui.Button("Aceptar", imgui.ImVec2(110, 24)) then 
                vPopup.KeyRepetido.visible[0] = false
                vPopup.KeyRepetido.add = true
                imgui.CloseCurrentPopup()
            end
            imgui.SameLine()
            if imgui.Button("Cancelar", imgui.ImVec2(110, 24)) then 
                vPopup.KeyRepetido.visible[0] = false
                vPopup.KeyRepetido.add = false
                imgui.CloseCurrentPopup()
            end
        end
        imgui.End()
    end
)

imgui.OnFrame( function() return vAllviews.visible[0] end,
    function() 
        imgui.SetNextWindowSize(imgui.ImVec2(300, 400), imgui.Cond.Always)
        imgui.SetNextWindowPos(imgui.ImVec2( 50, 50), imgui.Cond.FirstUseEver, imgui.ImVec2(0,0))
        imgui.Begin("Vista completa", vAllviews.visible, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize)
        if imgui.BeginTabBar("Tabs") then
            if imgui.BeginTabItem("Macros") then
                for index, macro in ipairs(global_data.list_macro) do
                    crearVistaItems(macro, index)
                end
                imgui.EndTabItem()
            end
            if imgui.BeginTabItem("Acciones") then
                imgui.EndTabItem()
            end
            if imgui.BeginTabItem("SubCommandos") then
                imgui.EndTabItem()
            end
        end
        
        if vPopup.Delete.visible[0] then
            imgui.OpenPopup("Delete")
        end
        if imgui.BeginPopupModal("Delete", _, imgui.WindowFlags.NoResize) then
            imgui.SetWindowSizeVec2(imgui.ImVec2(250, 100))
            imgui.TextWrapped('Seguro que quieres elimar el macro.')
            imgui.SetCursorPosY(55)
            imgui.Separator()
            imgui.SetCursorPosY(65)
            if imgui.Button("Aceptar", imgui.ImVec2(110, 24)) then 
                vPopup.Delete.visible[0] = false
                table.remove(global_data.list_macro, vPopup.Delete.index)
                imgui.CloseCurrentPopup()
            end
            imgui.SameLine()
            if imgui.Button("Cancelar", imgui.ImVec2(110, 24)) then
                vPopup.Delete.visible[0] = false
                imgui.CloseCurrentPopup()
            end
        end
        
    end
)

function CargarCommandosGlobal()
    sampRegisterChatCommand("as", function() vConfig.visible[0] = not vConfig.visible[0] end );
    sampRegisterChatCommand("cm", function() newMacro() end );
    sampRegisterChatCommand("vall", function() vAllviews.visible[0] = not vAllviews.visible[0] end );
end

function crearVistaItems(macro, index)
    if imgui.CollapsingHeader(macro.name) then
        imgui.Text("Key Activate: ")
        imgui.Text("\t" .. vk.parse_array_keys_from_string(macro.keys))
        imgui.Separator()
        imgui.Text("Commands:")
        imgui.Text("\t" .. helpMet.format_Commands(macro.cmds))
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
            helpMet.SaveDataJson(URL, global_data)
        end
        imgui.SameLine()
        if imgui.Button("Activar") then
            EjecutarCmd(macro)
        end
        imgui.SameLine()
        if imgui.Button("Editar") then
            EditarMacro(macro, index)
        end
        imgui.SameLine()
        if imgui.Button("Eliminar") then
            vPopup.Delete.index = index
            vPopup.Delete.visible[0] = true
        end
        
    end
end

function EditarMacro(macro, index)
    vCrearMacro.visible[0] = true
    vCrearMacro.index = index
    vCrearMacro.name = "Editar Macro"
    vCrearMacro.labelText = vk.parse_array_keys_from_string(macro.keys)
    vCrearMacro.inputNameMacro = new.char[64](macro.name)
    vCrearMacro.inputTimeWaitCmd[0] = macro.timeWaitCmds
    vCrearMacro.keysPress = macro.keys
    vCrearMacro.inputCommands = new.char[1024](helpMet.format_Commands(macro.cmds))
    vCrearMacro.status[0] = macro.status

end

function buttonAllView()
    vAllviews.visible[0] = true
    vConfig.visible[0] = false
end

function newMacro()
    vCrearMacro.visible[0] = not vCrearMacro.visible[0]
    vCrearMacro.name = "Nuevo Macro"
    limparViewMacro()
end

function limparViewMacro()
    vCrearMacro.inputNameMacro = new.char[64]()
    vCrearMacro.keysPress = {}
    vCrearMacro.inputTimeWaitCmd[0] = 1000
    vCrearMacro.inputCommands = new.char[1024]()
    vCrearMacro.status[0] = 0
    vCrearMacro.labelText = new.char[1024]()
    vCrearMacro.index = 0
    
end

function buttonCancelarViewMacro()
    limparViewMacro()

    vCrearMacro.visible[0] = false
end

function buttonAceptarViewMacro()
    --Verificar datos completos
    if ffi.string(vCrearMacro.inputNameMacro) == ""
    or #vCrearMacro.keysPress == 0 
    or vCrearMacro.inputTimeWaitCmd[0] < 0
    or ffi.string(vCrearMacro.inputCommands) == ""
    or vCrearMacro.grabando then
        vPopup.Error.visible[0] = true
    else
        
        --combierto datos a tabla
        local macro = {
            name = ffi.string(vCrearMacro.inputNameMacro),
            keys = vCrearMacro.keysPress,
            timeWaitCmds = vCrearMacro.inputTimeWaitCmd[0],
            cmds = helpMet.split_lines(ffi.string(vCrearMacro.inputCommands)),
            status = vCrearMacro.status[0],
            enable = true
        }
        
        local arrg1, arrg2, arrg3 = verificar_keys_existed(macro.keys)

        if arrg1 then
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
        
        function addDatos()
            if (vCrearMacro.index == 0 ) then
                table.insert(global_data.list_macro, macro)
                CreateMacro(macro)
            else
                global_data.list_macro[vCrearMacro.index].name = macro.name
                global_data.list_macro[vCrearMacro.index].keys = macro.keys
                global_data.list_macro[vCrearMacro.index].timeWaitCmds = macro.timeWaitCmds
                global_data.list_macro[vCrearMacro.index].cmds = macro.cmds
                global_data.list_macro[vCrearMacro.index].status = macro.status
                global_data.list_macro[vCrearMacro.index].enable = macro.enable
            end

            limparViewMacro()
            helpMet.SaveDataJson(URL, global_data)
            vCrearMacro.visible[0] = false

        end
            
    end
end

function verificar_keys_existed(keysComparter)
    for index, macro in pairs(global_data.list_macro) do
        helpMet.PrintTableValues(keysComparter)
        helpMet.PrintTableValues(macro.keys)
        local esIgual = false
        for i, tecla in ipairs(macro.keys) do
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

function CargarMacros()

    if global_data.list_macro == nil then
        global_data.list_macro = {}
    end

    local macros = global_data.list_macro

    for _, macro in ipairs(macros) do
        CreateMacro(macro)
    end
    sendConsoleMessageSamp("Se cargaron " .. #macros .. " macros.")

end

function CreateMacro(macro)
    _ = lua_thread.create(function()
        
        while true do
            wait(macro.timeWaitCmds)
    
            local comboPressed = vk.get_hotkey_pressed(macro.keys)
    
            local estado = isCharInAnyCar(PLAYER_PED)
    
            if comboPressed  and vConfig.macrosOn[0] and macro.enable then
           
                if macro.status == 0 then
                    EjecutarCmd(macro)
                elseif macro.status == 1 and estado then
                    EjecutarCmd(macro)
                elseif macro.status == 2 and not estado then  
                    EjecutarCmd(macro)
                end
                
            end
        end
    end)
end

function EjecutarCmd(funt, consoleCmd)

    local chatActive = sampIsChatInputActive()
    
    if chatActive and not consoleCmd then return end

    for i, cmd in ipairs(funt.cmds) do
        sampSendChat(cmd)

        if( i < #funt.cmds) then
            wait(funt.timeWaitCmds)
        end
    end
end

function sendConsoleMessageSamp(msg)
    local index = string.format("{FFFFFF}[ {1FDADC}%s {FFFFFF}]: ", thisScript().name)
    sampAddChatMessage(index .. msg, 0xD6DADC)
end
