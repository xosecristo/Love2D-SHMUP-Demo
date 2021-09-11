--default speed value--
	speed = 320

	player = {
		x = 190,
		y = 600,
		speed = speed,
		focus = (speed / 2),
		hitbox = love.graphics.newImage("sprites/player.png"),
		sprite = love.graphics.newImage("sprites/ship.png")
	}	

	background = { sprite = love.graphics.newImage("sprites/bg-sprite.png")}

	score = 0
	isAlive = true
	canShoot = true

	--Bullet Timer
	canShootTimerMax = 0.2
	canShootTimer = canShootTimerMax
	
	--Enemy timer
	createEnemyTimerMax = 0.1
	createEnemyTimer = createEnemyTimerMax

	--img
	bulletImg = nil
	enemyImg = nil

	--storage
	bullets = {}
	enemies = {}

-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
---
end

function love.load(arg)

	anim8 = require "lib/anim8"
	love.graphics.setDefaultFilter("nearest","nearest")

	player.grid = anim8.newGrid( 50, 75	, player.sprite:getWidth(), player.sprite:getHeight())
	
	player.animations = {
		still = anim8.newAnimation(player.grid('1-3', 1), 0.5),
		left  = anim8.newAnimation(player.grid('1-3', 2), 0.1),
		right = anim8.newAnimation(player.grid('1-3', 3), 0.1)		
	}

	background.grid = anim8.newGrid(450, 800, background.sprite:getWidth(), background.sprite:getHeight())
	
	background.animations = {
		still = anim8.newAnimation(background.grid('1-6', 1), 0.1)
	}

	--background = love.graphics.newImage("sprites/bg.png")
	bulletImg = love.graphics.newImage("sprites/bullet.png")
	enemyImg  = love.graphics.newImage("sprites/enemy.png")


	player.currentAnimation = player.animations.still
	background.currentAnimation = background.animations.still

---
end

function love.update(dt)


	player.currentAnimation:update(dt)
	background.currentAnimation:update(dt)
	
	isMoving = false	

	--goodbye monkee
	if love.keyboard.isDown("escape") then
     love.event.quit("quit")
    end

   -----------------------
   --HORIZONTAL MOVEMENT--
   -----------------------
	if love.keyboard.isDown("a", "left") then

		if player.x > 0 then
			--movement related
			player.x = player.x - (player.speed*dt)
			--animation related
			isMoving = true
			player.currentAnimation = player.animations.left
		end

	elseif love.keyboard.isDown("d","right") then
		
		if player.x < (love.graphics.getWidth() - 75)	then
			--movement related
			player.x = player.x + (player.speed*dt)
			--animation related
			isMoving = true
			player.currentAnimation = player.animations.right
		end	

	end

	---------------------
	--VERTICAL MOVEMENT--
	---------------------
	if love.keyboard.isDown("w", "up") then
		
		if player.y > 0 then
			--movement related
			player.y = player.y - (player.speed*dt)
			--animation related
			isMoving = true
			player.currentAnimation = player.animations.still
		end

	elseif love.keyboard.isDown("s","down") then
		
		if player.y < (love.graphics.getHeight() - 114) then
			--movement related
			player.y = player.y + (player.speed*dt)
			--animation related
			isMoving = true
			player.currentAnimation = player.animations.still
		end	

	end

	if isMoving == false then
		player.currentAnimation = player.animations.still
	end
	
	----------------------------
	--SHOOTINGSHOOTINGSHOOTING--
	----------------------------
	canShootTimer = canShootTimer - (3.3 * dt)

	if canShootTimer < 0 then
		canShoot = true
	end

	if love.keyboard.isDown("j") then
		--movemente related	
		--player.speed = player.focus

		if canShoot then
			--shooting related
			newBullet = { 
				x = player.x + (player.sprite:getWidth()/5.5), 
				y = player.y - 15, 
				img = bulletImg 
			}
			table.insert(bullets, newBullet)
			canShoot = false
			canShootTimer = canShootTimerMax
		end
	else
		--movement related
		player.speed = speed
	end


	for i, bullet in ipairs(bullets) do
		--bullet speed
		bullet.y = bullet.y - (500 * dt)
	  --byebye monkee
  	if bullet.y < -10 then 
			table.remove(bullets, i)
		end
	end

	---------------------------
	--ENEMY----ENEMY----ENEMY--
	---------------------------
	createEnemyTimer = createEnemyTimer - (1 * dt)

	if createEnemyTimer < 0 then
		createEnemyTimer = createEnemyTimerMax

		--create an enemy
		randomNumber = math.random(10, love.graphics.getWidth() - 10)
		newEnemy = { 
			x = randomNumber, 
			y = -10,
			img = enemyImg
		}
		table.insert(enemies, newEnemy)
	end	
	
	for i, enemy in ipairs(enemies) do

		--enemy speed
		enemy.y = enemy.y + (400 * dt)

		--goodbye monkey, goodbye
		if enemy.y > 850 then
			table.remove(enemies, i)
		end
	end

	-------------------------------
	--COLLISIONCOLLISIONCOLLISION--
	-------------------------------

	for i, enemy in ipairs(enemies) do
		
		---------------------------
		--COLLISION(BULLET/ENEMY)--
		---------------------------
		for j, bullet in ipairs(bullets) do
			if CheckCollision(enemy.x, enemy.y, enemyImg:getWidth(), enemyImg:getHeight(), bullet.x, bullet.y, bulletImg:getWidth(), bulletImg:getHeight()) then
				table.remove(bullets, j)
				table.remove(enemies, i)
				
				--Todos los shoo'em up tienen muchos números, ¿por qué este no?
				score = score + 10000000
			end
		end

		---------------------------
		--COLLISION(PLAYER&ENEMY)--
		---------------------------
		if CheckCollision(
			-- Enemy hitbox colission
			enemy.x, enemy.y, enemyImg:getWidth()*2, enemyImg:getHeight()*2, 
			-- Player Hitbox colission
			player.x, player.y, player.hitbox:getWidth()*1.5, player.hitbox:getHeight()*1.5) 
		then
			--goodbye monkee
			table.remove(enemies, i)

			--Aquí podría agregarle la animación de "morirse". 
			isAlive = false
		end
	end

	-----------
	--RESTART--
	-----------
	-- if not isAlive and love.keyboard.isDown('r') then
	-- 	-- remove all our bullets and enemies from screen
	-- 	bullets = {}
	-- 	enemies = {}

	-- 	-- reset timers
	-- 	canShootTimer = canShootTimerMax
	-- 	createEnemyTimer = createEnemyTimerMax

	-- 	-- move player back to default position
	-- 	player.x = 50
	-- 	player.y = 710

	-- 	-- reset our game state
	-- 	score = 0
	-- 	isAlive = true
	-- end
---
end

function love.draw(dt)
	--background
	background.currentAnimation:draw(background.sprite, nil, 1)

	--player
	--love.graphics.draw(player.playerImg, player.x, player.y, nil, 1.5)
	player.currentAnimation:draw(player.sprite, player.x, player.y, nil, 1.5)

	-- if isAlive then
	-- 	player.currentAnimation:draw(player.sprite, player.x, player.y, nil, 1.5)
	-- else
	-- 	love.graphics.print("UUUOOOOOOOOHH", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
	-- end

	--bullet	
	for i, bullet in ipairs(bullets) do
  	love.graphics.draw(bullet.img, bullet.x, bullet.y, nil)
	end

	--enemies
	for i, enemy in ipairs(enemies) do
		love.graphics.draw(enemy.img, enemy.x, enemy.y, nil, 2)
	end

---
end

 