local Game = require "Game"

function love.load()
	Game.Init()
end

function love.quit()
	Game.Done()
end

function love.update()
	Game.Update()
end

function love.draw()
	Game.Draw()
end

function love.keypressed(key)
	if key == "escape" then
		love.event.push("quit")
	else
		Game.KeyPressed(key)
	end
end