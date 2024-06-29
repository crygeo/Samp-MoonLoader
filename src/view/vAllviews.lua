local vAllviews = {
    visible = new.bool(false),
}


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