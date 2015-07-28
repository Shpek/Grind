local Heap = require "Heap"

-- Exported stuff goes here
local AStar = {}

-- Declarations of local functions

----
-- Exports
----

function AStar.FindPath(startNode, endNode, fnDist, fnNeightbours)
	local openSet = Heap.New(function(a, b) return a < b end)
	local openSetNodes = {}
	local closedSet = {}
	local distancesToStart = {}
	local cameFrom = {}
	Heap.Push(openSet, startNode, fnDist(startNode, endNode))
	distancesToStart[startNode] = 0
	local iters = 10
	while not Heap.IsEmpty(openSet) do
		local node, score = Heap.Pop(openSet)
		openSetNodes[node] = nil
		print("------- Opened node " .. tostring(node) .. " score " .. score)
		if node == endNode then
			local path = {node}
			while cameFrom[node] do
				node = cameFrom[node]
				table.insert(path, node)
			end
			return path
		end
		closedSet[node] = true
		local neighbours = fnNeightbours(node)
		for _, neighbour in ipairs(neighbours) do
			if not closedSet[neighbour] then
				local neighbourDelHandle = openSetNodes[neighbour]
				local shouldUpdateNode = not neighbourDelHandle
				local distToStart = distancesToStart[node] + fnDist(node, neighbour)
				if neighbourDelHandle and distToStart < distancesToStart[neighbour] then
					Heap.Del(openSet, neighbourDelHandle)
					shouldUpdateNode = true
				end
				print(
					"Neighbour " .. tostring(neighbour) ..
					" should update " .. tostring(shouldUpdateNode) ..
					" dist " .. distToStart)

				if shouldUpdateNode then
					cameFrom[neighbour] = node
					distancesToStart[neighbour] = distToStart
					local score = distToStart + fnDist(neighbour, endNode)
					print("Score " .. score)
					local delHandle = Heap.Push(openSet, neighbour, score)
					openSetNodes[neighbour] = delHandle
				end
			end
		end
		iters = iters - 1
		if iters == 0 then break end
	end
	return nil
end

----
-- Locals
----

-- return AStarExports

local TestMap = {
	{ 0, 0, 0, 0, 0, 0, 0 },
	{ 0, 0, 0, 1, 0, 0, 0 },
	{ 0, 2, 0, 1, 0, 3, 0 },
	{ 0, 0, 0, 1, 0, 0, 0 },
	{ 0, 0, 0, 0, 0, 0, 0 },
}

local FnNodeEq = function(a, b)
	return a.x == b.x and a.y == b.y
end

local FnNodeStr = function(a)
	return "(" .. tostring(a.x) .. ", " .. tostring(a.y) .. ")"
end

local Nodes = {}
local function NewNode(x, y)
	local ind = x * 1000 + y
	if Nodes[ind] then
		return Nodes[ind]
	end
	local node = setmetatable({ x = x, y = y }, { __eq = FnNodeEq, __tostring = FnNodeStr })
	Nodes[ind] = node
	return node
end

local function Dist(n1, n2)
	local x = n2.x - n1.x
	local y = n2.y - n1.y
	return x * x + y * y
end

local function Clamp(x, a, b)
	return x < a and a or (x > b and b or x)
end

local function Neighbours(n)
	local maxX = #TestMap[1]
	local maxY = #TestMap
	local neighbours = {}
	local startX = n.x == 1 and 1 or n.x - 1
	local endX = n.x == maxX and maxX or n.x + 1
	local startY = n.y == 1 and 1 or n.y - 1
	local endY = n.y == maxY and maxY or n.y + 1
	for x = startX, endX do
		for y = startY, endY do
			if (x ~= n.x or y ~= n.y) and TestMap[y][x] ~= 1 then
				table.insert(neighbours, NewNode(x, y))
			end
		end
	end
	return neighbours
end

local startNode, endNode

for y, row in ipairs(TestMap) do
	for x, column in ipairs(row) do
		local nodeVal = TestMap[y][x]
		if nodeVal == 2 then
			startNode = NewNode(x, y)
		elseif nodeVal == 3 then
			endNode = NewNode(x, y)
		end
	end
end


local path = AStar.FindPath(startNode, endNode, Dist, Neighbours)
if path == nil then
	print "No path"
else
	for _, node in pairs(path) do
		print(node)
	end
end