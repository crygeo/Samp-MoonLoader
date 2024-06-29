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