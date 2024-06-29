local vInventory = {
    visible = new.bool(false),
    keyboardMove = new.bool(true),
    title = "Inventario",
    description = ""

    
}

imgui.OnFrame( function() return vInventory.visible[0] end, function (player)
    local colorTitle = imgui.ImColorRGBA(255, 188, 5, 255)
    player.HideCursor = true
    imgui.SetNextWindowSize(imgui.ImVec2(200, 120), imgui.Cond.FirstUseEver)
    imgui.Begin('##inventario', vInventory.visible, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize + (vInventory.keyboardMove[0] and 0 or imgui.WindowFlags.NoMove) )
    imgui.TextMer(vInventory.title, 'center', 20, colorTitle)
    imgui.Spacing()
    imgui.Spacing()
    PrintParameter()
    --imgui.Text(helpMet.eliminarEspaciosExtras(vInventory.description))
    imgui.SetCursorPosX(180)
    
    imgui.MarginY(20)
    imgui.End()
end) 