local modulo = {}

local imgui = require 'src/imple/mimgui'
local new = imgui.new
local X, Y = getScreenResolution()

local settings = {}
--Vista de configuracion
local visible = new.bool(false)
local macrosOn = new.bool(true)
local accionesOn = new.bool(true)
local subComandosOn = new.bool(true)
local servicesOn = new.bool(true)

modulo.buttonNewMacro = nil
modulo.buttonNewAction = nil
modulo.buttonNewSubCommand = nil
modulo.buttonAllView = nil


imgui.OnFrame( function() return visible[0] end,
    function()
        imgui.SetNextWindowSize(imgui.ImVec2(194, 120), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(X / 2, Y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        
        imgui.Begin("Configuracion", visible, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize)
        imgui.Text("Configuracion del procesos.")
        imgui.MarginY(15)
        if imgui.Checkbox("Macros On", macrosOn) then 
            settings.macrosOn = macrosOn[0] 
        end imgui.SameLine()
        imgui.MarginX(25)
        if imgui.Checkbox("SubCommandos On", subComandosOn) then
            settings.subComandosOn = subComandosOn[0] 
        end
        if imgui.Checkbox("Acction On", accionesOn) then
            settings.accionesOn = accionesOn[0]
        end imgui.SameLine()
        imgui.MarginX(21)
        if imgui.Checkbox("Servicios On", servicesOn) then
            settings.servicesOn = servicesOn[0]
        end
        imgui.MarginY(10)
        
        imgui.Separator()
        imgui.MarginY(5)
        if imgui.Button("Crear Macro") then if modulo.buttonNewMacro ~= nil then  end end imgui.SameLine()
        if imgui.Button("Crear Acction") then if modulo.buttonNewAction ~= nil then modulo.buttonNewAction() end end imgui.SameLine()
        if imgui.Button("Crear SubCommando") then if modulo.buttonNewSubCommand ~= nil then modulo.buttonNewSubCommand() end end 
        imgui.MarginY(5)
        imgui.Separator()
        imgui.MarginY(5)
        if imgui.Button("Ver All") then if modulo.buttonAllView ~= nil then modulo.buttonAllView() end end
        imgui.MarginY(5)
        imgui.End()
    end
)


function modulo.CargarSettings(stg)
    settings = stg

    macrosOn = new.bool(stg.macrosOn)
    accionesOn = new.bool(stg.accionesOn)
    subComandosOn = new.bool(stg.subComandosOn)
    servicesOn = new.bool(stg.servicesOn)

end

function modulo.OpenView()
    visible[0] = true
end

function modulo.OpenOrCloseView()
    visible[0] = not visible[0]
end

function modulo.CloseView()
    visible[0] = false
end

function modulo.IsVisible() 
    return visible[0] 
end 


return modulo