local vSubCommandCrud = {
    visible = new.bool(false),
    name = "",
    index = 0,

    inputName = new.char[64](),
    inputCommand = new.char[64](),
    inputCommands = new.char[1024](),
    timeWaitCmds = new.int(1000),
}

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