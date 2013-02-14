local Game = require "Game"

function love.load()
	Game.Init()
end

function love.quit()
	Game.Done()
end

function love.update()
	Game.Update(love.timer.getMicroTime())
end

function love.draw()
	Game.Draw()
	love.graphics.printf(tostring(love.timer.getFPS()), 10, 10, 100, "left")
end

function love.keypressed(key)
	if key == "escape" then
		love.event.push("quit")
	else
		Game.KeyPressed(key)
	end
end
