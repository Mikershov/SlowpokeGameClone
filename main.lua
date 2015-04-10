-- скрываем статус бар
-- Белый фон по умолчению
-- Черный шрифт по умолчению
display.setStatusBar(display.HiddenStatusBar)
display.setDefault("background", 1)
display.setDefault("fillColor", 0)

-- Переменные
local physics
local enemy = {} 
local border = {}
local hero
local timerText
local velocityUPx
local velocityUPy 

-- Подключаем физический движок
physics = require("physics")
physics.start();
physics.setGravity(0,0)
physics.setDrawMode("hybrid")

-- Описание границ экрана
border[1] = display.newRect(192,0, 384,1)
border[2] = display.newRect(384,display.actualContentHeight/2, 1, display.actualContentHeight)
border[3] = display.newRect(192,display.actualContentHeight, 384,1)
border[4] = display.newRect(0,display.actualContentHeight/2, 1, display.actualContentHeight)
-- Добавляем границы экрана в физический мир
for i = 1, 4 do
	physics.addBody(border[i], "static",  {friction=0, bounce=0})
end


-- Тест физики
hero = display.newRect(100, 100, 50,50)
physics.addBody(hero, {friction=0, bounce=1, density=0.0})
hero.isFixedRotation = true
hero:setLinearVelocity(50, 50)

local function moveHero()
	local vx, vy = hero:getLinearVelocity()
	
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
	
	hero:setLinearVelocity(vx+velocityUPx, vy+velocityUPy)
	
	return true
end

timer.performWithDelay(4000, moveHero, 0)


-- Описание врагов


-- Описание героя