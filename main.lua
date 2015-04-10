-- скрываем статус бар
-- Белый фон по умолчению
-- Черный шрифт по умолчению
display.setStatusBar(display.HiddenStatusBar)
display.setDefault("background", 1)
display.setDefault("fillColor", 0)

-- менеджер сцен
local composer = require "composer"
composer.gotoScene("gameplay")

-- Обработчик кнопки back
local function onKeyEvent( event )
    return true
end

Runtime:addEventListener( "key", onKeyEvent )