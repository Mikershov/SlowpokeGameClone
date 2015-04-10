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
		if composer.getSceneName("previous") == "menu" then
			composer.removeScene("menu")
		end
		
		------------- ПЕРЕМЕННЫЕ
		local physics
		local enemy = {} 
		local enemyTimer = {} 
		local border = {}
		local hero
		local velocityUPx
		local velocityUPy 
		local Eclosure
		local timeCount
		local gameOver = false
		local firstLaunch = true
		local sec = 100
		local mlSec = 100

		local playText = display.newText({parent=sceneGroup,text="Move the green square to start", x=display.actualContentWidth/2, y=display.actualContentHeight/2+70, height=40, width=380, font="Ebrima", fontSize=27, align="center"})

		local currentPlayTime = display.newText({parent=sceneGroup,text="00:00", x=display.actualContentWidth/2, y=20, height=40, width=200, font="Ebrima", fontSize=20, align="center"})
		currentPlayTime.isVisible = false
		

		------------- ПОДКЛЮЧАЕМ ФИЗИЧЕСКИЙ ДВИЖОК
		physics = require("physics")
		physics.start();
		physics.setGravity(0,0)


		------------- ОПИСАНИЕ ГРАНИЦ ЭКРАНА
		border[1] = display.newRect(sceneGroup,192,-1, 384,1)
		border[2] = display.newRect(sceneGroup,385,display.actualContentHeight/2, 1, display.actualContentHeight)
		border[3] = display.newRect(sceneGroup,192,display.actualContentHeight+1, 384,1)
		border[4] = display.newRect(sceneGroup,-1,display.actualContentHeight/2, 1, display.actualContentHeight)
		-- Добавляем границы экрана в физический мир
		for i = 1, 4 do
			physics.addBody(border[i], "static", {friction=0, bounce=0})
		end


		------------- ОПИСАНИЕ ВРАГОВ
		-- ускорение врагов
		local function moveEnemy(enemy)
			local vx, vy = enemy:getLinearVelocity()
			
			if vx < 0 then
				velocityUPx = -20
			else
				velocityUPx = 20
			end
			
			if vy < 0 then
				velocityUPy = -20
			else
				velocityUPy = 20
			end
			
			enemy:setLinearVelocity(vx+velocityUPx, vy+velocityUPy)
			
			return true
		end
		
		-- Дефолтное позиционирование врагов
		enemy[1] = display.newRect(sceneGroup,20, 20, 40,40)
		enemy[2] = display.newRect(sceneGroup,10, display.actualContentHeight-10, 20,20)
		enemy[3] = display.newRect(sceneGroup,364, display.actualContentHeight-20, 40,40)
		enemy[4] = display.newRect(sceneGroup,354, 30, 60,60)
		-- Добавляем врагов в физический мир
		for i = 1, 4 do
			physics.addBody(enemy[i], {friction=0, bounce=1, density=0})
			enemy[i]:setFillColor(0, 0, 0.7)
			enemy[i].myName = "enemy"
			--enemy[i].isFixedRotation = true
		end
		

		-------------- ТАЙМЕР	
		local function timerUP()
			sec = sec + 100
			mlSec = mlSec + 100
			currentPlayTime.text = math.floor(sec/1000).."."..math.floor(mlSec/10)
			
			if mlSec >= 1000 then
				mlSec = 100
			end
		end


		-------------- ОПИСАНИЕ ГЕРОЯ
		hero = display.newRect(sceneGroup,display.actualContentWidth/2, display.actualContentHeight/2, 70, 70)
		hero:setFillColor(0, 0.7, 0)
		physics.addBody(hero, "kinematic", {friction=0, bounce=0})
		hero.isBullet = true
		hero.isSensor = true
		hero.isFixedRotation = true
		hero.myName = "hero"

		-- Обработчик тача героя
		function hero:touch(event)
			if event.phase == "began" then
				self.markX = self.x
				self.markY = self.y    
				
				if firstLaunch then
					firstLaunch = false
					playText.isVisible = false
					currentPlayTime.isVisible = true
					timeCount = timer.performWithDelay(100,timerUP,0)
					
					-- начальная скорость и направление
					enemy[1]:setLinearVelocity(math.random(10,200), math.random(10,100))
					enemy[2]:setLinearVelocity(math.random(10,200), -math.random(10,100))
					enemy[3]:setLinearVelocity(-math.random(10,200), -math.random(10,100))
					enemy[4]:setLinearVelocity(-math.random(10,200), math.random(10,100))
					
					-- Ставим слушатели ускорения
					for i=1, 4 do
						Eclosure = function() return moveEnemy(enemy[i]) end
						enemyTimer[i] = timer.performWithDelay(4000, Eclosure, 0)
					end
				end
				
			elseif event.phase == "moved" then
				-- трекинг
				if not gameOver then
					local x = (event.x - event.xStart) + self.markX
					local y = (event.y - event.yStart) + self.markY
					self.x, self.y = x, y
				end
				
				-- Ограничения по границам
				if self.contentBounds.xMax > 384 then
					self.x = 350
				end
				
				if self.contentBounds.xMin < 0 then
					self.x = 35
				end
				
				if self.contentBounds.yMax > display.actualContentHeight then
					self.y = display.actualContentHeight - 35
				end
				
				if self.contentBounds.yMin < 0 then
					self.y = 35
				end
			end
			
			return true
		end
		hero:addEventListener("touch", hero)

		-- отложенная функция вызова меню
		local function stopWorld()
			
			local options = {
				effect = "slideDown",
				time = 300,
				params = {timePlay=currentPlayTime.text}
			}
			composer.gotoScene("menu", options)
			
		end

		-- Обработчик столкновений
		local function heroCollision(self, event)
			if event.other.myName == "enemy" then
				physics.pause()
				gameOver = true
				timer.cancel(timeCount)
				
				if tonumber(settings.bestTime) < tonumber(currentPlayTime.text) then
					settings.bestTime = currentPlayTime.text
					saveTable(settings, "settings.json")
				end
				
				for i=1, 4 do
					timer.cancel(enemyTimer[i])
				end
				
				timer.performWithDelay(1000, stopWorld, 1)
			end
		end
		hero.collision = heroCollision
		hero:addEventListener("collision", hero)
		
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