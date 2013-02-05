local level = require "level"
local drawLevel = require "drawLevel"
local player = require "player"

local screenx = 500
local screeny = 500
local gridx = 25
local gridy = 25
local stepx = screenx / gridx
local stepy = screeny / gridy

local grid = {}
local buttonsPressed = {}

local levelDef = {
	width = 7,
	height = 7,
	sparseRadius = 1,
	roomsWidth = { 10, 25 },
	roomsHeight = { 10, 25 },
	-- seed = 10,
}

local levelDrawParams = {
	cellWidth = 30,
	cellHeight = 20,
	roomWidth = 26,
	roomHeight = 16,
	doorWidth = 6,
	roomColor = { 100, 100, 100 },
	playerColor = { 128, 0, 0 },
	endPointColor = { 92, 185, 0 }, 
	doorColor = { 160, 80, 0 },
}

local levelInst, playerInst

function initLevel()
	levelInst = level.create(levelDef)
	local endPoints = {}
	for room in pairs(levelInst.endPoints) do
		table.insert(endPoints, room)
	end
	local startRoom = endPoints[math.random(1, #endPoints)]
	playerInst = player.create(levelInst, startRoom)
end	

function love.load()
	for x = 1, gridx do
		grid[x] = {}
	end
	love.graphics.setMode(640, 480, false, true, 0)
	initLevel()
end

function love.mousepressed(x, y, button)
	buttonsPressed[button] = true
end

function love.mousereleased(x, y, button)
	buttonsPressed[button] = nil
end

function love.keypressed(key)
	if key == "escape" then
		love.event.push("quit")
	elseif key == "w" then
		playerInst:moveToRoom("N")
	elseif key == "s" then
		playerInst:moveToRoom("S")
	elseif key == "a" then
		playerInst:moveToRoom("W")
	elseif key == "d" then
		playerInst:moveToRoom("E")
	end
end

function love.draw()
	-- love.graphics.setColor(255, 255, 255)
	-- love.graphics.setLineStyle("rough")
	-- for y = 1, gridy do
	-- 	local yscreen = (y - 1) * stepy
	-- 	-- love.graphics.line(0, yscreen, screenx, yscreen)
	-- end
	-- for x = 1, gridx do
	-- 	local xscreen = (x - 1) * stepx
	-- 	love.graphics.setColor(255, 255, 255)
	-- 	-- love.graphics.line(xscreen, 0, xscreen, screeny)
	-- 	local column = grid[x]
	-- 	for y = 1, gridy do
	-- 		local el = column[y]
	-- 		if el then
	-- 			local yscreen = (y - 1) * stepy
	-- 			love.graphics.setColor(0, 255, 0)
	-- 			love.graphics.rectangle("fill", xscreen, yscreen, stepx - 1, stepy - 1)
	-- 		end
	-- 		if x <= levelInst.def.width and y <= levelInst.def.height then
	-- 			local room = levelInst.rooms[x][y]
	-- 			if room then
	-- 				local yscreen = (y - 1) * stepy
	-- 				-- drawDoors(room, xscreen, yscreen)
	-- 				if room.endPoint then
	-- 					love.graphics.setColor(0, 255, 0)
	-- 				else
	-- 					love.graphics.setColor(255, 0, 0)
	-- 				end
	-- 				love.graphics.rectangle("fill", xscreen, yscreen, stepx, stepy)					
	-- 			end
	-- 		end
	-- 	end
	-- end

	drawLevel.draw(levelInst, playerInst, 20, 250, levelDrawParams)
	if buttonsPressed["l"] then
		local x, y = getGridXYAtScreenXY(love.mouse.getX(), love.mouse.getY())
		-- grid[x][y] = true
		initLevel()
	elseif buttonsPressed["r"] then
		local x, y = getGridXYAtScreenXY(love.mouse.getX(), love.mouse.getY())
		grid[x][y] = false
	end
end

function getGridXYAtScreenXY(x, y)
	local gridX = math.floor(x / stepx) + 1
	local gridY = math.floor(y / stepy) + 1
	return gridX, gridY
end

function drawDoors(room, xscreen, yscreen)
	local passages = { N = true, W = true, S = true, E = true }
	for passage in pairs(room.passages) do
		passages[passage] = nil
	end
	for wall in pairs(passages) do
		if wall == "N" then
			love.graphics.setColor(255, 0, 0)
			love.graphics.rectangle("fill", xscreen, yscreen, stepx, 1)
		end
		if wall == "S" then
			love.graphics.setColor(255, 0, 0)
			love.graphics.rectangle("fill", xscreen, yscreen + stepy, stepx, 1)
		end
		if wall == "E" then
			love.graphics.setColor(255, 0, 0)
			love.graphics.rectangle("fill", xscreen + stepx, yscreen, 1, stepy)
		end
		if wall == "W" then
			love.graphics.setColor(255, 0, 0)
			love.graphics.rectangle("fill", xscreen, yscreen, 1, stepy)
		end
	end
end