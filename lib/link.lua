
 local imgui = require('imgui')

 function imgui.Link(link)
        if status_hovered then
            local p = imgui.GetCursorScreenPos()
            imgui.TextColored(imgui.ImVec4(0, 0.5, 1, 1), 'traducido y adaptado por ollydbg#6383')
            imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y + imgui.CalcTextSize(link).y), imgui.ImVec2(p.x + imgui.CalcTextSize(link).x, p.y + imgui.CalcTextSize(link).y), imgui.GetColorU32(imgui.ImVec4(0, 0.5, 1, 1)))
        else
            imgui.TextColored(imgui.ImVec4(0, 0.3, 0.8, 1), 'traducido y adaptado por ollydbg#6383')
        end
        if imgui.IsItemClicked() then os.execute('explorer '..'https://discord.com/invite/nCUrj2W')
        elseif imgui.IsItemHovered() then
            status_hovered = true else status_hovered = false
        end
    end
    