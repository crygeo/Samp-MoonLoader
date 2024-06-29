local imgui = require 'mimgui'
local new = imgui.new



function loadFonts(a, b)
    local fonts = {}

    local path = getFolderPath(0x14) .. '\\trebucbd.ttf'
    local gr = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()

    for size = a, b do
        fonts[size] = imgui.GetIO().Fonts:AddFontFromFileTTF(path, size, nil, gr)
    end
    return fonts
end

local fonts

imgui.OnInitialize(function()
    fonts = loadFonts(10, 25)
end)


function imgui.TextMer(text, aling, size, color)

    if size == nil or size == 0 then size = 14 end
    if color == nil then color = imgui.ImColorRGBA(255, 255, 255, 255) end

    imgui.PushFont(fonts[size])
    imgui.PushStyleColor(imgui.Col.Text, color)

    local width = imgui.GetWindowWidth()
    local widthText = imgui.CalcTextSize(text).x
    
    if aling == 'center' then
        imgui.SetCursorPosX((width - widthText) / 2)
    elseif aling == 'right' then
        imgui.SetCursorPosX(width - widthText)
    elseif aling == 'left' then
        imgui.SetCursorPosX(0)
    end

    imgui.Text(text)
    imgui.PopFont()
    imgui.PopStyleColor()
end

function imgui.MarginY(i)
    local y = imgui.GetCursorPosY()
    imgui.SetCursorPosY(y + i)
end

function imgui.MarginX(i)
    local x = imgui.GetCursorPosX()
    imgui.SetCursorPosX(x + i)
end

function imgui.ImColorRGBA(r, g, b, a)
    return imgui.ImVec4(r/255, g/255, b/255, a/255)
end

function imgui.ImColorHex(hex)
    hex = hex:gsub("#", "")
    hex = hex:gsub("{", "")
    hex = hex:gsub("}", "")

    local r = tonumber(hex:sub(1, 2), 16) or 0
    local g = tonumber(hex:sub(3, 4), 16) or 0
    local b = tonumber(hex:sub(5, 6), 16) or 0
    local a = tonumber(hex:sub(7, 8) or "FF", 16) or 255

    r = r / 255
    g = g / 255
    b = b / 255
    a = a / 255

    return imgui.ImVec4(r, g, b, a)
end

function imgui.PoputError(msg, visible)
    if visible[0] then
        imgui.OpenPopup("Error")
    end
    if imgui.BeginPopupModal("Error", _, imgui.WindowFlags.NoResize) then
        imgui.Text(msg)
        imgui.MarginY(20)
        imgui.Separator()
        imgui.MarginY(10)
        if imgui.Button("Aceptar", imgui.ImVec2(250, 24)) then
            visible[0] = false
            imgui.CloseCurrentPopup()
        end
    end
end

function imgui.PoputAdvertencia(title, msg, visible, result)
    if visible[0] then
        imgui.OpenPopup("Advertencia")
    end
    if imgui.BeginPopupModal("Advertencia", _, imgui.WindowFlags.NoResize) then
        imgui.SetWindowSizeVec2(imgui.ImVec2(300, 140)) 
        imgui.Text(title)
        imgui.Text(msg)
        imgui.Text('Seguir con el proceso?')
        imgui.MarginY(10)
        imgui.Separator()
        imgui.MarginY(10)
        imgui.MarginX(35)
        if imgui.Button("Aceptar", imgui.ImVec2(110, 24)) then 
            visible[0] = false
            result = true
            imgui.CloseCurrentPopup()
        end
        imgui.SameLine()
        imgui.MarginX(10)
        if imgui.Button("Cancelar", imgui.ImVec2(110, 24)) then 
            visible[0] = false
            result = false
            imgui.CloseCurrentPopup()
        end
    end
end

return imgui