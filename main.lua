-- скрываем статус бар
-- Белый фон по умолчению
-- Черный шрифт по умолчению
display.setStatusBar(display.HiddenStatusBar)
display.setDefault("background", 1)
display.setDefault("fillColor", 0)

------------- ПЕРЕМЕННЫЕ
local physics
local enemy = {} 
local border = {}
local hero
local velocityUPx
local velocityUPy 
local gameOver = false
local firstLaunch = true
local sec = 100
local mlSec = 100
local animateDone = false

local overlay = display.newRect(display.actualContentWidth/2, display.actualContentHeight/2, display.actualContentWidth, display.actualContentHeight)
overlay.alpha = 0.7
overlay.isVisible = false

local playText = display.newText({text="Move the green square to start", x=display.actualContentWidth/2, y=display.actualContentHeight/2+70, height=40, width=380, font="Ebrima", fontSize=27, align="center"})
local gameOverText = display.newText({text="Touch anything to continue", x=display.actualContentWidth/2, y=display.actualContentHeight/2, height=40, width=380, font="Ebrima", fontSize=27, align="center"})
gameOverText:setFillColor(1)

local currentPlayTime = display.newText({text="00:00", x=display.actualContentWidth/2, y=20, height=40, width=200, font="Ebrima", fontSize=20, align="center"})
currentPlayTime.isVisible = false


------------- ПОДКЛЮЧАЕМ ФИЗИЧЕСКИЙ ДВИЖОК
physics = require("physics")
physics.start();
physics.setGravity(0,0)
physics.setDrawMode("hybrid")


------------- ОПИСАНИЕ ГРАНИЦ ЭКРАНА
border[1] = display.newRect(192,-1, 384,1)
border[2] = display.newRect(385,display.actualContentHeight/2, 1, display.actualContentHeight)
border[3] = display.newRect(192,display.actualContentHeight+1, 384,1)
border[4] = display.newRect(-1,display.actualContentHeight/2, 1, display.actualContentHeight)
-- Добавляем границы экрана в физический мир
for i = 1, 4 do
	physics.addBody(border[i], "static", {friction=0, bounce=0})
end


------------- ОПИСАНИЕ ВРАГОВ
-- ускорение врагов
local function moveEnemy(self)
	local vx, vy = self:getLinearVelocity()
	
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
	
	self:setLinearVelocity(vx+velocityUPx, vy+velocityUPy)
	
	return true
end

enemy[1] = display.newRect(20, 20, 40,40)
enemy[2] = display.newRect(10, display.actualContentHeight-10, 20,20)
enemy[3] = display.newRect(364, display.actualContentHeight-20, 40,40)
enemy[4] = display.newRect(354, 30, 60,60)
-- Добавляем врагов в физический мир
for i = 1, 4 do
	physics.addBody(enemy[i], {friction=0, bounce=1, density=0})
	enemy[i]:setFillColor(0, 0, 0.7)
	enemy[i].myName = "enemy"
	
	--timer.performWithDelay(4000, moveEnemy, 0)
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

timeCount = timer.performWithDelay(100,timerUP,0)



-------------- ОПИСАНИЕ ГЕРОЯ
hero = display.newRect(display.actualContentWidth/2, display.actualContentHeight/2, 70, 70)
hero:setFillColor(0, 0.7, 0)
physics.addBody(hero, "kinematic", {friction=0, bounce=0})
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
			
			enemy[1]:setLinearVelocity(math.random(10,30), math.random(10,30))
			enemy[2]:setLinearVelocity(math.random(20,50), -30)
			enemy[3]:setLinearVelocity(-30 ,-30)
			enemy[4]:setLinearVelocity(-30, math.random(10,30))
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
		elseif self.contentBounds.xMin < 0 then
			self.x = 35
		elseif self.contentBounds.yMax > display.actualContentHeight then
			self.y = display.actualContentHeight - 35
		elseif self.contentBounds.yMin < 0 then
			self.y = 35
		end
    end
    
    return true
end
hero:addEventListener("touch", hero)

-- геймовер экран
local function timeDone()
	animateDone = true
end

local function stopWorld()
	overlay.isVisible = true
	gameOverText:toFront()
	currentPlayTime:toFront()
	currentPlayTime.size = 30
	currentPlayTime.text = "TIME: "..currentPlayTime.text
	currentPlayTime:setFillColor(1)
	transition.to(currentPlayTime, {time=400, y=display.actualContentHeight/2-50, onComplete=timeDone})
end

-- Обработчик столкновений
local function heroCollision(self, event)
    if event.other.myName == "enemy" and gameOver == false then
		print("COLLIDE")
		physics.pause()
		gameOver = true
		timer.cancel(timeCount)
		timer.performWithDelay(400, stopWorld, 1)
	end
end
hero.collision = heroCollision
hero:addEventListener("collision", hero)

-- Ввыводим оверлей наверх
overlay:toFront()

-- Обработчик тача оверлея
function overlay:touch(event)
	--local touchAllow = false 
	
	if event.phase == "began" then
		touchAllow = true
		--print("OK")
	end
	
	if event.phase == "ended" and animateDone == true then
		--print("OK")
		local function newGame()
			physics.start()
			gameOver = false
		end
		
		transition.to(hero, {time=300, x=display.actualContentWidth/2, y=display.actualContentHeight/2, onComplete=newGame})
		transition.to(enemy[1], {time=300, x=20, y=20})
		transition.to(enemy[2], {time=300, x=10, y=display.actualContentHeight-10})
		transition.to(enemy[3], {time=300, x=364, y=display.actualContentHeight-20})
		transition.to(enemy[4], {time=300, x=354, y=30})
		
		overlay.isVisible = false
		gameOverText:toBack()
		
		currentPlayTime.isVisible = false
		currentPlayTime.size = 20
		currentPlayTime.text = ""
		currentPlayTime:setFillColor(0)
	end
end
overlay:addEventListener("touch", overlay)