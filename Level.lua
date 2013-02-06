-- Exported stuff goes here
local LevelExports = {} 

-- Forward declarations of local functions
local CreateRoom, ShuffleCopy, CheckSparse, CarvePassageTo

local Directions = { "N", "W", "S", "E" }

local OppositeDirections = { 
	N = "S",  
	W = "E", 
	S = "N", 
	E = "W", 
}

local DirectionFix = {
	N = function(x, y) return x, y - 1 end,
	W = function(x, y) return x - 1, y end,
	S = function(x, y) return x, y + 1 end,
	E = function(x, y) return x + 1, y end,
}

-- local levelDef = {
-- 	width = 15,
-- 	height = 15,
-- 	sparseRadius = 1,
-- 	roomsWidth = { 10, 25 },
-- 	roomsHeight = { 10, 25 },
-- 	seed = 123,
-- }

function LevelExports.Create(levelDef)
	local rooms = {}
	for i = 1, levelDef.width do
		rooms[i] = {}
	end
	if levelDef.seed then
		math.randomseed(levelDef.seed)
	end
	local startx = math.random(levelDef.width)
	local starty = math.random(levelDef.height)
	local level = {
		rooms = rooms,
		endPoints = {},
		def = levelDef,
	}
	local room = CarvePassageTo(startx, starty, level)
	local numPassages = 0
	for _ in pairs(room.passages) do
		numPassages = numPassages + 1
	end
	if numPassages == 0 or numPassages == 1 then
		level.endPoints[room] = true
		room.endPoint = true
	end
	return level
end

function CreateRoom(levelDef, x, y)
	local width = math.random(levelDef.roomsWidth[1], levelDef.roomsWidth[2])
	local height = math.random(levelDef.roomsHeight[1], levelDef.roomsHeight[2])
	local room = {
		width = width,
		height = height,
		x = x,
		y = y,
		passages = {},
	}
	return room
end

function ShuffleCopy(arr)
	local ret = { arr[1], }
	for i = 2, #arr do
		local j = math.random(1, i)
		ret[i] = ret[j]
		ret[j] = arr[i]
	end
	return ret
end

function CheckSparse(x, y, cameFrom, level)
	if not level.def.sparseRadius then
		return true
	end
	local radius = level.def.sparseRadius
	local limitx, limity
	if cameFrom == "N" then
		limitx = { x - radius, x + radius }
		limity = { y, y + radius }
	elseif cameFrom == "W" then
		limitx = { x, x + radius }
		limity = { y - radius, y + radius }
	elseif cameFrom == "S" then
		limitx = { x - radius, x + radius }
		limity = { y - radius, y }
	elseif cameFrom == "E" then
		limitx = { x - radius, x }
		limity = { y - radius, y + radius }
	end
	local width = level.def.width
	local height = level.def.height	
	for nx = limitx[1], limitx[2] do
		for ny = limity[1], limity[2] do
			-- if nx < 1 or ny < 1 or nx > width or ny > height or level.rooms[nx][ny] then
			-- 	return false
			-- end
				if nx >= 1 and ny >= 1 and nx <= width and ny <= height and level.rooms[nx][ny] then
					return false
				end
		end
	end
	return true
end

function CarvePassageTo(x, y, level)
	local room = CreateRoom(level.def, x, y)
	assert(not level.rooms[x][y])
	level.rooms[x][y] = room
	local width = level.def.width
	local height = level.def.height
	local directions = ShuffleCopy(Directions)
	for _, dir in ipairs(directions) do
		local nx, ny = DirectionFix[dir](x, y)
		if nx >= 1 and ny >= 1 and nx <= width and ny <= height and not level.rooms[nx][ny] then
			local cameFrom = OppositeDirections[dir]
			if CheckSparse(nx, ny, cameFrom, level) then
				local newRoom = CarvePassageTo(nx, ny, level)
				room.passages[dir] = newRoom
				newRoom.passages[cameFrom] = room
			end
		end
	end
	if not next(room.passages) then
		level.endPoints[room] = true
		room.endPoint = true
	end
	return room
end

return LevelExports