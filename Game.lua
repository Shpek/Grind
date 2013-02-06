local Level = require "Level"
local DrawLevel = require "DrawLevel"
local Player = require "Player"

-- Exported stuff goes here
GameExports = {}

-- Forward declarations of local functions
local InitLevel

local LevelDef = {
	width = 7,
	height = 7,
	sparseRadius = 1,
	roomsWidth = { 10, 25 },
	roomsHeight = { 10, 25 },
	-- seed = 10,
}

local LevelDrawParams = {
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

local LevelInst, PlayerInst

function GameExports.Init()
	InitLevel()
end

function GameExports.Done()
end

function GameExports.Update()
end

function GameExports.Draw()
	DrawLevel.Draw(LevelInst, PlayerInst, 20, 250, LevelDrawParams)
end

function GameExports.KeyPressed(key)
	if key == "w" then
		PlayerInst:MoveToRoom("N")
	elseif key == "s" then
		PlayerInst:MoveToRoom("S")
	elseif key == "a" then
		PlayerInst:MoveToRoom("W")
	elseif key == "d" then
		PlayerInst:MoveToRoom("E")
	end
end

function InitLevel()
	LevelInst = Level.Create(LevelDef)
	local endPoints = {}
	for room in pairs(LevelInst.endPoints) do
		table.insert(endPoints, room)
	end
	local startRoom = endPoints[math.random(1, #endPoints)]
	PlayerInst = Player.Create(levelInst, startRoom)
end

return GameExports