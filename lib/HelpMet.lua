local dkjson = require("lib/dkjson-master/dkjson")

helpMet = {}

function helpMet.GetDataArchivo(url)
    local archivo = io.open( GetUrlThis(url), "r")

    if archivo then
        local contenido = archivo:read("*all")
        archivo:close()

        local success, datos = pcall(dkjson.decode, contenido)

        if success then
            return datos
        else
            print("Error al decodificar el archivo JSON:", datos)
        end
    else
        print("Error al abrir el archivo JSON")
    end
end

function helpMet.SaveDataJson(url, table)
    local archivo = io.open( GetUrlThis(url), "w")
    local jsonStr = dkjson.encode(table)
    if archivo then
        archivo:write(jsonStr)
        archivo:close()
        print("Tabla guardada en datos.json")
    else
        print("Error al abrir el archivo para escritura")
    end
end

function GetUrlThis(url)
    return getWorkingDirectory() .. "/" .. url
end 

function helpMet.PrintTableValues(tbl, prefix)
    prefix = prefix or ""
    for k, v in pairs(tbl) do
        local keyStr = tostring(k)
        if type(v) == "table" then
            print(prefix .. "[" .. keyStr .. "] (table):")
            helpMet.PrintTableValues(v, prefix .. "-----")
        else
            print(prefix .. "[" .. keyStr .. "] = " .. tostring(v))
        end
    end
end

function helpMet.existe_en_lista(tabla, elemento)
    if tabla == nil then return false end

    for _, v in pairs(tabla) do
        if v == elemento then
            return true
        end
    end
    return false
end

function helpMet.split_lines(text)
    local lines = {}
    for line in text:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    return lines
end

function helpMet.format_arrays(cmds)
    local result = ""
    for i, cmd in ipairs(cmds) do
        result = result .. cmd
        if i < #cmds then
            result = result .. "\n"
        end
    end
    return result
end

function helpMet.format_bool(bool)
    if bool then
        return "true"
    else
        return "false"
    end
end

function helpMet.translate_movement_type(movementType)
    if movementType == 0 then
        return "All"
    elseif movementType == 1 then
        return "In Car"
    elseif movementType == 2 then
        return "Walking"
    else
        return "Unknown"
    end
end


function helpMet.parse_int_bool(numer)
    if numer == 0 then return nil end
    if numer == 1 then return true end
    if numer == 2 then return false end
    return nil
end

function helpMet.contains(p1, list)
	for k,v in ipairs(list) do 
		if p1:lower():match(v) then return true end
	end
	return false 
end

function helpMet.eliminarEspaciosExtras(text)
    local arr = {}
    for line in text:gmatch("[^\r\n]+") do
        local str = line:gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
        table.insert(arr, str)
    end
    return table.concat(arr, "\n")
end

return helpMet