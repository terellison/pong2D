push = require 'push'
Class = require 'class'
require 'Paddle'
require 'Ball'


WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 400

function love.load()
	love.graphics.setDefaultFilter('nearest','nearest')
	
	love.window.setTitle('Pong')
	
	math.randomseed(os.time())
	
	smallFont = love.graphics.newFont('font.ttf', 8)
	
	scoreFont = love.graphics.newFont('font.ttf', 32) -- font for the score(s)
	
	love.graphics.setFont(smallFont)

	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		fullscreen = false,
		resizable = false,
		vsync = true
	})
	
	player1Score = 0
	player2Score = 0
	
	player1 = Paddle(10, 30, 5, 20)
	player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
	
	ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)
	
	gameState = 'start'
	servingPlayer = math.random(1,2)
end


function love.update(dt)
	if gameState == 'serve' then
		ball.dy = (math.random(-1,1) * math.random(250,250))
		
		ball.dx = math.random(150,250)
		
		if servingPlayer == 2 then
			ball.dx = ball.dx * -1
		end
	
		
	elseif gameState == 'play' then
	
		if ball:collides(player1) then
			ball.dx = -(ball.dx * 1.03)
			ball.x = player1.x + 5
			
			if ball.dy < 0 then
				ball.dy = -math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end
		end
		
		if ball:collides(player2) then
			ball.dx = -(ball.dx * 1.03)
			ball.x = player2.x - 4
			
			-- randomize the y velocity
			if ball.dy < 0 then
				ball.dy = -math.random(40, 150)
			else
				ball.dy = math.random(40, 150)
			end
		end
		
		 -- detect upper and lower screen boundary collision and reverse if collided
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
        end

        -- -4 to account for the ball's size
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
        end
		
		-- same for left and right bounds
		if ball.x <= 0 then
            player2Score = player2Score + 1
			servingPlayer = 1
			gameState = 'serve'
			ball:reset()
        end

        -- -4 to account for the ball's size
        if ball.x >= VIRTUAL_WIDTH - 4 then
            player1Score = player1Score + 1
			servingPlayer = 2
			gameState = 'serve'
            ball:reset()
        end
	end
	
	
	-- player 1 movement
	if love.keyboard.isDown('w') then
		player1.dy = -PADDLE_SPEED + 30
	elseif love.keyboard.isDown('s') then
		player1.dy = PADDLE_SPEED
	else
		player1.dy = 0
	end
	
	-- player 2 movement
	if love.keyboard.isDown('up') then
		player2.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('down') then
		player2.dy = PADDLE_SPEED
	else
		player2.dy = 0
	end
	
	if gameState == 'play' then
		ball:update(dt)
	end
	
	player1:update(dt)
	player2:update(dt)
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
		
	elseif key == 'enter' or key == 'return' then
		if gameState == 'start' then
			gameState = 'play'
		else
			gameState = 'start'
			
			ball:reset()
		end
	end
end


function love.draw()
	push:apply('start')
	
	love.graphics.clear(40/255, 45/255, 52/255, 255/255)
	
	love.graphics.setFont(smallFont)
	
	if gameState == 'start' then
		love.graphics.printf('Hello start state!', 0, 20, VIRTUAL_WIDTH, 'center')
	else
		love.graphics.printf('Hello play state!', 0, 20, VIRTUAL_WIDTH, 'center')
	end
	
	
	-- print the scores
	love.graphics.setFont(scoreFont)
	
	love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 -50,
		VIRTUAL_HEIGHT / 3)
		
	love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
		VIRTUAL_HEIGHT / 3)
	
	
	player1:render() -- left (player 1) paddle
	
	player2:render() -- right (player 2) paddle
	
	ball:render() -- ball
	
	displayFPS()
	
	push:apply('end')
end

function displayFPS()
	love.graphics.setFont(smallFont)
	love.graphics.setColor(0, 255/255, 0, 255/255)
	love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end