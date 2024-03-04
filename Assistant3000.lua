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

local vMacroCrud = {
    visible = new.bool(false),
    name = "",
    index = 0,

    buttonText = "Grabar KeyHot",
    grabando = false,
    labelKeysActivate = "",
    
    inputNameMacro = new.char[64](),
    keysActivate = {},
    inputTimeWaitCmd = new.int(1000),
    inputCommands = new.char[1024](),
    status = new.int(0),

}

local vActionCrud = {
    visible = new.bool(false),
    name = "",
    index = 0,

    buttonText = "Grabar KeyHot",
    labelKeysActivate = "",
    grabando = false,

    inputNameAction = new.char[64](),
    inputTextActivate = new.char[255](),
    inputTextDesactivate = new.char[1024](),
    inputCommands = new.char[1024](),
    timeWaitCmds = new.int(1000),
    timeWaitDesactivateAction = new.int(5000),
    autoActivate = new.bool(true),
    keysActivate = {}
    
}

local vSubCommandCrud = {
    visible = new.bool(false),
    name = "",
    index = 0,

    inputName = new.char[64](),
    inputCommand = new.char[64](),
    inputCommands = new.char[1024](),
    timeWaitCmds = new.int(1000),
}

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

local vPopup = {
    Error = { 
        visible = new.bool(false),
        msg = ""
    },
    Delete = {
        visible = new.bool(false),
    },
    KeyRepetido = {
        visible = new.bool(false),
    }
}

local global_data = {}

function main()
    --cargar datos del json
    global_data = helpMet.GetDataArchivo(URL)

    if global_data == nil then
        global_data = {}
        global_data.settings = {
            macrosOn = true,
            accionesOn = true,
            subComandosOn = true,
        }
    end
    
    vConfig.macrosOn = new.bool(global_data.settings.macrosOn)
    vConfig.accionesOn = new.bool(global_data.settings.accionesOn)
    vConfig.subComandosOn = new.bool(global_data.settings.subComandosOn)

    while not isSampAvailable() do wait(50) end
    CargarCommandosGlobal()
    CargarMacros()
    CargarAction()
    CargarSubCommand()
    
end




imgui.OnFrame( function() return vConfig.visible[0] end,
    function()
        imgui.SetNextWindowSize(imgui.ImVec2(194, 120), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(X / 2, Y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        
        imgui.Begin("Configuracion", vConfig.visible, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize)
        imgui.Text("Configuracion del procesos.")
        if imgui.Checkbox("Macros On", vConfig.macrosOn) then
            global_data.settings.macrosOn = vConfig.macrosOn[0]
        end
        if imgui.Checkbox("Acction On", vConfig.accionesOn) then
            global_data.settings.accionesOn = vConfig.accionesOn[0]
        end
        if imgui.Checkbox("SubCommandos On", vConfig.subComandosOn) then
            global_data.settings.subComandosOn = vConfig.subComandosOn[0]
        end
        imgui.Separator()
        if imgui.Button("Crear Macro") then newMacro() end imgui.SameLine()
        if imgui.Button("Crear Acction") then newAction() end imgui.SameLine()
        if imgui.Button("Crear SubCommando") then newSubCommand() end imgui.Separator()
        if imgui.Button("Ver All") then buttonAllView() end
        imgui.End()
    end
)

imgui.OnFrame( function() return vMacroCrud.visible[0] end, 
    function()
        imgui.SetNextWindowSize(imgui.ImVec2(194, 120), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(X / 2, Y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        
        imgui.Begin(vMacroCrud.name, vMacroCrud.visible, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize)
        
        imgui.InputText('Name', vMacroCrud.inputNameMacro, 128)
        if imgui.Button(vMacroCrud.buttonText) then 
            
            if not vMacroCrud.grabando then
                thread_GrabarKey:run(vMacroCrud)
            else
                if thread_GrabarKey ~= nil then
                    thread_GrabarKey:terminate(thread_GrabarKey)
                end
                vMacroCrud.labelKeysActivate = ""
                vMacroCrud.keysActivate = {}
                vMacroCrud.buttonText = "Grabar KeyHot"
                vMacroCrud.grabando = false
            end
        end imgui.SameLine()
        imgui.Text(vMacroCrud.labelKeysActivate)
        imgui.InputInt("Time between commands ms", vMacroCrud.inputTimeWaitCmd, 1000, 1000)
        imgui.InputTextMultiline("Commands", vMacroCrud.inputCommands, 0x400,  imgui.ImVec2(0, 100))
        imgui.Separator()
        imgui.Text("Estado de activicion del macro")
        imgui.RadioButtonIntPtr("All", vMacroCrud.status, 0) imgui.SameLine()
        imgui.RadioButtonIntPtr("In Car", vMacroCrud.status, 1) imgui.SameLine()
        imgui.RadioButtonIntPtr("Walking", vMacroCrud.status, 2) 
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

        viewPoputError() -- Implementa la vista de error

        if vPopup.KeyRepetido.visible[0] then
            imgui.OpenPopup("HotKeyRepetido")
        end
        if imgui.BeginPopupModal("HotKeyRepetido", _, imgui.WindowFlags.NoResize) then
            imgui.SetWindowSizeVec2(imgui.ImVec2(300, 140)) 
            imgui.TextWrapped('La combinacion es igual al macro:')
            imgui.Text(vPopup.KeyRepetido.macro.name)
            imgui.TextWrapped('Aun desea agregar el macro?')
            imgui.SetCursorPosY(90)
            imgui.Separator()
            imgui.SetCursorPosY(100)
            imgui.SetCursorPosX(35)
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
                    crearVistaItemsMacros(macro, index)
                end
                imgui.EndTabItem()
            end
            if imgui.BeginTabItem("Acciones") then
                for index, acction in ipairs(global_data.list_acction) do
                    crearVistaItemsAction(acction, index)
                end
                imgui.EndTabItem()
            end
            if imgui.BeginTabItem("SubCommandos") then
                for index, subcmd in ipairs(global_data.list_subcommand) do
                    crearVistaItemsSubCommand(subcmd, index)
                end
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
                vPopup.Delete.remove = true
                imgui.CloseCurrentPopup()
            end
            imgui.SameLine()
            if imgui.Button("Cancelar", imgui.ImVec2(110, 24)) then
                vPopup.Delete.visible[0] = false
                vPopup.Delete.remove = false
                imgui.CloseCurrentPopup()
            end
        end
        
    end
)

imgui.OnFrame( function() return vActionCrud.visible[0] end,
    function() 
        local x, y = nil
        imgui.SetNextWindowPos(imgui.ImVec2( 50, 50), imgui.Cond.FirstUseEver, imgui.ImVec2(0,0))
        imgui.GetStyle().WindowPadding = imgui.ImVec2(15, 15)
        imgui.Begin(vActionCrud.name, vActionCrud.visible, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize)
            imgui.InputText(" Name", vActionCrud.inputNameAction, 64)
            imgui.InputText(" Text for activate", vActionCrud.inputTextActivate, 255)
            imgui.InputTextMultiline(" Commands", vActionCrud.inputCommands, 1024)
            imgui.InputInt(" Time wait to activete command", vActionCrud.timeWaitCmds, 1000, 1000)
            imgui.Checkbox(" Auto Activar", vActionCrud.autoActivate)
            
            if not vActionCrud.autoActivate[0] then
                imgui.MarginY(10)
                if imgui.BeginChild('Name', imgui.ImVec2(520, 200), true) then
                    if imgui.Button(vActionCrud.buttonText) then
                        if not vActionCrud.grabando then
                            thread_GrabarKey:run(vActionCrud)
                        else
                            if thread_GrabarKey ~= nil then
                                thread_GrabarKey:terminate(thread_GrabarKey)
                            end
                            vActionCrud.labelKeysActivate = ""
                            vActionCrud.keysActivate = {}
                            vActionCrud.buttonText = "Grabar KeyHot"
                            vActionCrud.grabando = false
                        end
                    end
                    imgui.SameLine()
                    imgui.Text(vActionCrud.labelKeysActivate)
                    imgui.InputTextMultiline(" Text for desactivate", vActionCrud.inputTextDesactivate, 1024)
                    imgui.InputInt(" Time for auto desactivate", vActionCrud.timeWaitDesactivateAction, 1000,1000)
                end
                imgui.EndChild()
            else
                vActionCrud.labelKeysActivate = ""
                vActionCrud.keysActivate = {}
                vActionCrud.timeWaitDesactivateAction[0] = 5000
            end
            imgui.MarginY(10)
            imgui.Separator()
            imgui.SetCursorPosX(100)
            imgui.MarginY(10)
            if imgui.Button("Aceptar", imgui.ImVec2(100, 24)) then
                buttonAceptarViewAction()
            end
            imgui.SameLine()
            imgui.SetCursorPosX(250)
            if imgui.Button("Cancelar", imgui.ImVec2(100, 24)) then
                buttonCancelarViewAction()
            end
            viewPoputError() -- Implementa la vista de error
            imgui.End()
    end
)

imgui.OnFrame( function() return vSubCommandCrud.visible[0] end ,
    function() 
        imgui.SetNextWindowPos(imgui.ImVec2( 50, 50), imgui.Cond.FirstUseEver, imgui.ImVec2(0,0))
        imgui.Begin(vSubCommandCrud.name, vSubCommandCrud.visible, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize)
            imgui.InputText("Name", vSubCommandCrud.inputName, 64)
            imgui.InputText("Command active", vSubCommandCrud.inputCommand, 64)
            imgui.InputTextMultiline("Commands", vSubCommandCrud.inputCommands, 1024)
            imgui.InputInt(" Time wait to activete command", vSubCommandCrud.timeWaitCmds, 1000, 1000)
            imgui.MarginY(10)
            imgui.Separator()
            imgui.SetCursorPosX(100)
            imgui.MarginY(10)
            if imgui.Button("Aceptar", imgui.ImVec2(100, 24)) then
                buttonAceptarSubCommand()
            end
            imgui.SameLine()
            imgui.SetCursorPosX(250)
            if imgui.Button("Cancelar", imgui.ImVec2(100, 24)) then
                buttonCancelarSubCommand()
            end
            viewPoputError()
        imgui.End()
    end
)

function viewPoputError()
    if vPopup.Error.visible[0] then
        imgui.OpenPopup("Error")
    end
    if imgui.BeginPopupModal("Error", _, imgui.WindowFlags.NoResize) then
        imgui.Text(vPopup.Error.msg)
        imgui.SetCursorPosY(45 + imgui.CalcTextSize(vPopup.Error.msg).y)
        imgui.Separator()
        imgui.SetCursorPosY(55 + imgui.CalcTextSize(vPopup.Error.msg).y)
        if imgui.Button("Aceptar", imgui.ImVec2(250, 24)) then
            vPopup.Error.visible[0] = false
            imgui.CloseCurrentPopup()
        end
    end
end

function imgui.MarginY(i)
    local y = imgui.GetCursorPosY()
    imgui.SetCursorPosY(y + i)
end

function CargarCommandosGlobal()
    sampRegisterChatCommand("as", function() vConfig.visible[0] = not vConfig.visible[0] end );
    sampRegisterChatCommand("vall", function() vAllviews.visible[0] = not vAllviews.visible[0] end );
    sampRegisterChatCommand("nm", function() newMacro() end );
    sampRegisterChatCommand("na", function() newAction() end );
    sampRegisterChatCommand("nsc", function() newSubCommand() end );
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
            table.remove(global_data.list_macro, vPopup.Delete.index)
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
            table.remove(global_data.list_acction, vPopup.Delete.index)
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
            table.remove(global_data.list_subcommand, vPopup.Delete.index)
            SaveData();
        end
    end)
end

function EditarMacro(macro, index)
    vMacroCrud.visible[0] = true
    vMacroCrud.index = index
    vMacroCrud.name = "Editar Macro"
    vMacroCrud.labelKeysActivate = vk.parse_array_keys_from_string(macro.keysActivate)
    vMacroCrud.inputNameMacro = new.char[64](macro.name)
    vMacroCrud.inputTimeWaitCmd[0] = macro.timeWaitCmds
    vMacroCrud.keysActivate = macro.keysActivate
    vMacroCrud.inputCommands = new.char[1024](helpMet.format_arrays(macro.commands))
    vMacroCrud.status[0] = macro.status

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


function buttonAllView()
    vAllviews.visible[0] = true
    vConfig.visible[0] = false
end

function newMacro()
    if vMacroCrud.visible[0] ~= true then 
        vMacroCrud.visible[0] = true
        vMacroCrud.name = "Nuevo Macro"
        limpiarViewMacro()
    end
end

function newAction()
    if vActionCrud.visible[0] ~= true then 
        vActionCrud.visible[0] = true 
        vActionCrud.name = "Nuevo Acction"
        limpiarViewAction()
    end
end

function newSubCommand()
    if vSubCommandCrud.visible[0] ~= true then 
        vSubCommandCrud.visible[0] = true 
        vSubCommandCrud.name = "Nuevo SubCommand"
        limpiarViewSubCommand()
    end
end

function limpiarViewMacro()
    vMacroCrud.inputNameMacro = new.char[64]()
    vMacroCrud.keysActivate = {}
    vMacroCrud.inputTimeWaitCmd[0] = 1000
    vMacroCrud.inputCommands = new.char[1024]()
    vMacroCrud.status[0] = 0
    vMacroCrud.labelKeysActivate = new.char[1024]()
    vMacroCrud.index = 0
    
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
                table.insert(global_data.list_macro, macro)
                CreateMacro(macro)
            else
                global_data.list_macro[vMacroCrud.index].name = macro.name
                global_data.list_macro[vMacroCrud.index].keysActivate = macro.keysActivate
                global_data.list_macro[vMacroCrud.index].timeWaitCmds = macro.timeWaitCmds
                global_data.list_macro[vMacroCrud.index].commands = macro.commands
                global_data.list_macro[vMacroCrud.index].status = macro.status
                global_data.list_macro[vMacroCrud.index].enable = macro.enable
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
                table.insert(global_data.list_acction, acction)
                -- Funcion para activar la accíon
                CreateAccion(acction);
            else
                global_data.list_acction[index].enable = acction.enable
                global_data.list_acction[index].name = acction.name
                global_data.list_acction[index].textActive = acction.textActive
                global_data.list_acction[index].textDesactive = acction.textDesactive
                global_data.list_acction[index].commands = acction.commands
                global_data.list_acction[index].timeWaitCmds = acction.timeWaitCmds
                global_data.list_acction[index].timeWaitDesactivateAction = acction.timeWaitDesactivateAction
                global_data.list_acction[index].autoActivate = acction.autoActivate
                global_data.list_acction[index].keysActivate = acction.keysActivate
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
                table.insert(global_data.list_subcommand, subCmd)
            else
                sampUnregisterChatCommand(global_data.list_subcommand[index].command)
                global_data.list_subcommand[index].enable = subCmd.enable
                global_data.list_subcommand[index].name = subCmd.name
                global_data.list_subcommand[index].command = subCmd.command
                global_data.list_subcommand[index].commands = subCmd.commands
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
    for k, v in ipairs(global_data.list_subcommand) do
        if v.command == subCommand.command and index ~= k then
            return true
        end
    end
    return false
end

function verificar_keys_existed(keysComparter)
    for index, macro in pairs(global_data.list_macro) do
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
    if global_data.list_acction == nil then
        global_data.list_acction = {}
    end

    local acciones = global_data.list_acction
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
    if accion.enable and global_data.settings.accionesOn then
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

    if global_data.list_macro == nil then
        global_data.list_macro = {}
    end

    local macros = global_data.list_macro

    for _, macro in ipairs(macros) do
        CreateMacro(macro)
    end
    sendConsoleMessageSamp("Se cargaron " .. #macros .. " macros.")

end

function CargarSubCommand()

    if global_data.list_subcommand == nil then
        global_data.list_subcommand = {}
    end

    local subcmds = global_data.list_subcommand

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
            
            if comboPressed  and global_data.settings.macrosOn and macro.enable and not vMacroCrud.visible[0] then
                
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

function EjecutarCmd(funt, consoleCmd)

    local chatActive = sampIsChatInputActive()
    
    if chatActive and consoleCmd ~= true then return  end

    for i, cmd in ipairs(funt.commands) do
        local isCmd, value = obtenerValorDesdeLlaves(cmd)

        if isCmd then
            sampSendChat(value)
        else
            wait(value)
        end

    end
end

function obtenerValorDesdeLlaves(texto)
    -- Buscar el patrón de llaves con un número dentro
    local patron = "{(%d+)}"
    local valor = texto:match(patron) -- Buscar el primer valor que coincida con el patrón

    if valor then
        return false, tonumber(valor) -- Convertir el valor encontrado a número y devolverlo
    else
        return true, texto -- Devolver nil si no se encontró ningún valor dentro de las llaves
    end
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
    helpMet.SaveDataJson(URL, global_data)
end
