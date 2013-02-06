-- Exported stuff goes here
local DrawLevelExports = {}

-- Forward declarations of local functions
local DrawDoors

-- local params = {
-- 	cellWidth = 30,
-- 	cellHeight = 30,
-- 	roomWidth = 25,
-- 	roomHeight = 25,
-- 	doorWidth = 5,
-- 	roomColor = { 255, 0, 0 },
-- 	endPointColor = { 0, 255, 0}, 
-- 	playerColor = { 255, 0, 0}, 
-- 	doorColor = { 0, 0, 255 },
-- }

function DrawLevelExports.Draw(level, player, screenx, screeny, params)
	local width = level.def.width
	local height = level.def.height
	local xoffset = (params.cellWidth - params.roomWidth) / 2
	local yoffset = (params.cellHeight - params.roomHeight) / 2
	for x = 1, width do
		local xscreen = (x - 1) * params.cellWidth + screenx
		local column = level.rooms[x]
		for y = 1, height do
			local room = column[y]
			if room and player:IsRoomExplored(room) then
				local yscreen = (y - 1) * params.cellHeight + screeny
				-- DrawDoors(room, xscreen, yscreen)
				if player.room == room then
					love.graphics.setColor(params.playerColor)
				elseif room.endPoint then
					love.graphics.setColor(params.endPointColor)
				else
					love.graphics.setColor(params.roomColor)
				end
				love.graphics.rectangle("fill", xscreen + xoffset, yscreen + yoffset, params.roomWidth, params.roomHeight)
				DrawDoors(room, xscreen, yscreen, params)
			end
		end
	end
end

function DrawDoors(room, xscreen, yscreen, params)
	for passage in pairs(room.passages) do
		if passage == "N" then
			love.graphics.setColor(params.doorColor)
			love.graphics.rectangle(
				"fill", 
				xscreen + (params.cellWidth - params.doorWidth) / 2, 
				yscreen - (params.cellHeight - params.roomHeight) / 2, 
				params.doorWidth, 
				params.cellHeight - params.roomHeight
			)
		end
		if passage == "S" then
			love.graphics.setColor(params.doorColor)
			love.graphics.rectangle(
				"fill", 
				xscreen + (params.cellWidth - params.doorWidth) / 2, 
				yscreen + (params.cellHeight - params.roomHeight) / 2 + params.roomHeight, 
				params.doorWidth, 
				params.cellHeight - params.roomHeight
			)
		end
		if passage == "E" then
			love.graphics.setColor(params.doorColor)
			love.graphics.rectangle(
				"fill", 
				xscreen + params.roomWidth + (params.cellWidth - params.roomWidth) / 2, 
				yscreen + (params.cellHeight - params.doorWidth) / 2,  
				params.cellWidth - params.roomWidth,
				params.doorWidth
			)
		end
		if passage == "W" then
			love.graphics.setColor(params.doorColor)
			love.graphics.rectangle(
				"fill", 
				xscreen - (params.cellWidth - params.roomWidth) / 2, 
				yscreen + (params.cellHeight - params.doorWidth) / 2,  
				params.cellWidth - params.roomWidth,
				params.doorWidth
			)
		end
	end
end

return DrawLevelExports