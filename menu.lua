local composer = require( "composer" )

local scene = composer.newScene()

-- "scene:create()"
function scene:create( event )
    local sceneGroup = self.view
	
end


-- "scene:show()"
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
		
    elseif ( phase == "did" ) then
		composer.removeScene("gameplay")
		
		-- библиотека виджетов
		local widget = require("widget")
		widget.setTheme("widget_theme_android_holo_light")
		
		display.newText({parent=sceneGroup,text="GAME OVER", x=display.actualContentWidth/2, y=display.actualContentHeight/2-70, height=40, width=380, font="Ebrima", fontSize=27, align="center"})
		display.newText({parent=sceneGroup,text="CURRENT TIME: "..event.params.timePlay.." s", x=display.actualContentWidth/2, y=display.actualContentHeight/2-10, height=40, width=380, font="Ebrima", fontSize=27, align="center"})
		display.newText({parent=sceneGroup,text="BEST TIME: "..settings.bestTime.." s", x=display.actualContentWidth/2, y=display.actualContentHeight/2+50, height=40, width=380, font="Ebrima", fontSize=27, align="center"})
		
		--Обработчик кнопки и кнопка
		local function backButtonFun(e)
			if ("ended" == e.phase) then
				local options =
				{
					effect = "slideUp",
					time = 300
				}
				composer.gotoScene('gameplay', options)
			end
		end
		
		local backButton = widget.newButton
		{
			left = 100,
			top = display.actualContentHeight/2+130,
			label = "TRY AGAIN",
			onEvent = backButtonFun
		}
		sceneGroup:insert(backButton)
		
    end
end


-- "scene:hide()"
function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        
    elseif ( phase == "did" ) then
		
    end
end


-- "scene:destroy()"
function scene:destroy( event )
    local sceneGroup = self.view
	
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene