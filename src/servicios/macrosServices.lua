local view = require'src/view/vMacroCrud'
local asis = require'Assistant3000'
local helpMet = require("src/imple/helpMet")

local modelo = {}
local treend_macro = {}

modelo.All_Macros = {}

function modelo.load()
    for id, mac in pairs(modelo.All_Macros) do
        treend_macro[id] = activarMacro(mac)
    end
end

function modelo.add(macro)
end

function modelo.remove(id)
end

function modelo.update(macro)
end

function modelo.get()
end

function activarMacro(macro)
    local tree = lua_thread.create(function()
        
        while true do
            
            local comboPressed = vk.get_hotkey_pressed(macro.keysActivate)
            
            local estado = isCharInAnyCar(PLAYER_PED)
            
            if comboPressed  and global_data.settings.macrosOn and macro.enable and not view.IsVisible() then
                
                if macro.status == 0 then
                    helpMet.RunCommands(macro)
                elseif macro.status == 1 and estado then
                    helpMet.RunCommands(macro)
                elseif macro.status == 2 and not estado then  
                    helpMet.RunCommands(macro)
                end
                
            end
            wait(macro.timeWaitCmds)
        end
    end)

    return tree
end


return modelo