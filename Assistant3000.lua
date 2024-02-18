script_author('CaJlaT')
script_name('KeyBoard')
script_version('2.1')


local imgui = require 'imgui'
local helpMet = require 'HelpMet'


local URL = "config/macrosDef.json"
local viewConfig = {
    visible = imgui.ImBool(true),
    
}
local items = imgui.ImInt(0)

function main()

    --cargar datos del json
    local config = helpMet.GetDataArchivo(URL)
    viewConfig.macros = config.Macros
    viewConfig.acciones = config.Accions
    viewConfig.subComandos = config.SubComandos

    sampRegisterChatCommand('as', function() viewConfig.visible.v = not viewConfig.visible.v end)
    while true do
		wait(0)
		imgui.Process = viewConfig.visible.v
	end
end

function imgui.OnDrawFrame()
	local X, Y = getScreenResolution()
	if viewConfig.visible.v then
        imgui.Begin("Settings", viewConfig.visible, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize)
    
        
        imgui.Text("Configuracion del procesos.") -- Display some text (you can use a format strings too)
        imgui.Checkbox("Macros On", viewConfig.macrosOn) -- Edit bools storing our window open/close state
        imgui.Checkbox("Acction On", viewConfig.acctionOn)
        imgui.Checkbox("SubCommandos On", viewConfig.subComandosOn)
        imgui.Separator()
        if  imgui.Button("Crear Macro") then  
            vCrearMacro.visible[0] = not vCrearMacro.visible[0] 
            settingView[0] = not settingView[0] 
        end
        imgui.SameLine()        
        if  imgui.Button("Crear Evento")  then  printString("Provando Macro", 3000) end
        imgui.SameLine()        
        if  imgui.Button("Crear Sub Cmd") then  printString("Provando Macro", 3000) end
        imgui.SameLine()        
       
    
        imgui.End()
	end
end
