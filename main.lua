debug = true

function love.load(arg)
	anim8 = require "lib/anim8"
	love.graphics.setDefaultFilter("nearest","nearest")

	--default speed value--
	speed = 320

	player = {
		x = 190,
		y = 600,
		speed = speed,
		focus = (speed / 2),
		sprite = love.graphics.newImage("sprites/ship.png")
	}
	
	player.grid = anim8.newGrid( 50, 75, player.sprite:getWidth(), player.sprite:getHeight())
	
	background = love.graphics.newImage("sprites/bg.png")
	
	

	player.animations = {
		still = anim8.newAnimation(player.grid('1-3',1), 0.5),
		left  = anim8.newAnimation(player.grid('1-3',2), 0.1),
		right = anim8.newAnimation(player.grid('1-3',3), 0.1)		
	}

	player.currentAnimation = player.animations.still


	canShoot = true

	canShootTimerMax = 0.2
	canShootTimer = canShootTimerMax

	bulletImg = nil

	bullets = {}

	bulletImg  = love.graphics.newImage("sprites/bullet.png")

end

function love.update(dt)

	player.currentAnimation:update(dt)
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
	if love.keyboard.isDown("w","up") then
		
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
	
	----------------------------
	--SHOOTINGSHOOTINGSHOOTING--
	----------------------------

	canShootTimer = canShootTimer - (1 * dt)
	if canShootTimer < 0 then
		canShoot = true
	end

	if love.keyboard.isDown("j") then

		--movemente related
		player.speed = player.focus
		--shooting related
		if canShoot then
			newBullet = { x = player.x + (player.sprite:getWidth()/5), y = player.y, img = bulletImg }
			table.insert(bullets, newBullet)
			canShoot = false
			canShootTimer = canShootTimerMax
		end

	else
		
		--movement related
		player.speed = speed

	end

	for i, bullet in ipairs(bullets) do
		
		bullet.y = bullet.y - (250 * dt)
	  --byebye monkee
  	if bullet.y < -10 then 
			table.remove(bullets, i)
		end
		
	end

	if isMoving == false then
		player.currentAnimation = player.animations.still
	end

end

function love.draw(dt)
	love.graphics.draw(background, 0 , 0, nill)
	player.currentAnimation:draw(player.sprite, player.x, player.y, nil, 1.5)

for i, bullet in ipairs(bullets) do
  love.graphics.draw(bullet.img, bullet.x, bullet.y)
end

end 