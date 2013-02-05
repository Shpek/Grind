player = {} -- Exported stuff goes here

local Player = {}

function player.create(level, room)
	local newPlayer = {
		level = level,
		room = room,
		exploredRooms = {},
		stats = {
			level = 1,
			xp = 0,
			gold = 0,
		},
	}
	setmetatable(newPlayer, { __index = Player })
	newPlayer.exploredRooms[room] = true
	return newPlayer
end

function Player:moveToRoom(dir)
	local newRoom = self.room.passages[dir]
	if not newRoom then
		return false
	end
	self.room = newRoom
	self.exploredRooms[newRoom] = true
	return true
end

function Player:isRoomExplored(room)
	return self.exploredRooms[room]
end

return player