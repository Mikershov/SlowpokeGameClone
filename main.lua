-- скрываем статус бар
-- Белый фон по умолчению
-- Черный шрифт по умолчению
display.setStatusBar(display.HiddenStatusBar)
display.setDefault("background", 1)
display.setDefault("fillColor", 0)

-- json библиотека
local json = require("json")

-- запись локальной таблицы
function saveTable(t, filename)
    local path = system.pathForFile(filename, system.DocumentsDirectory)
    local file = io.open(path, "w")
    if file then
        local contents = json.encode(t)
        file:write(contents)
        io.close(file)
        return true
    else
        return false
    end
end

-- чтение локальной таблицы
function loadTable(filename)
    local path = system.pathForFile(filename, system.DocumentsDirectory)
    local contents = ""
    local myTable = {}
    local file, errStr = io.open(path, "r")
    if file then
         contents = file:read( "*a" )
         myTable = json.decode(contents);
         io.close(file)
         return myTable 
    end
    return nil
end

settings = loadTable("settings.json")

-- Если первый запуск, то лучшее время ставим в 0
if(settings == nil) then
	settings = {}
	settings.bestTime = 0
	saveTable(settings, "settings.json")
end

-- менеджер сцен
local composer = require "composer"
composer.gotoScene("gameplay")

-- Обработчик кнопки back
local function onKeyEvent(event)
    if (event.keyName == "back") then
        local platformName = system.getInfo("platformName")
        if (platformName == "Android") then
            if composer.getSceneName("current") == "menu" then
				local options =
				{
					effect = "slideUp",
					time = 300
				}
				composer.gotoScene('gameplay', options)
			else
				return true
			end
        end
    end
    return false
end

Runtime:addEventListener("key", onKeyEvent)