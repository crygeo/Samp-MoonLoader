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

function GetUrlThis(url)
    return getWorkingDirectory() .. "/" .. url
end 

return helpMet