-- Exported stuff goes here
local Heap = {}

-- Declarations of local functions
local SiftUp, SiftDown, CheckConsistency

----
-- Exports
----

function Heap.New(fnIsGreater)
	if not fnIsGreater then
		fnIsGreater = function(a, b) return a > b end
	end
	return { fnIsGreater = fnIsGreater, }
end

function Heap.Push(heap, el, val)
	table.insert(heap, { el, val, #heap + 1 })
	return SiftUp(heap, #heap)
end

function Heap.IsEmpty(heap)
	return #heap == 0
end

function Heap.Pop(heap)
	local numEls = #heap
	if numEls == 0 then
		return nil
	end
	local el = heap[1]
	local last = heap[numEls]
	heap[1] = last
	last[3] = 1
	heap[numEls] = nil
	SiftDown(heap, 1)
	return el[1], el[2]
end

function Heap.Peek(heap)
	if #heap == 0 then
		return nil
	end
	local el = heap[1]
	return el[1], el[2]
end

function Heap.Del(heap, handle)
	local ind = handle[3]
	local numEls = #heap
	if ind == numEls then
		heap[ind] = nil
	else
		local last = heap[numEls]
		heap[ind] = last
		last[3] = ind
		heap[numEls] = nil
		if numEls > 1 then
			ind = SiftUp(heap, ind)[3]
			SiftDown(heap, ind)
		end
	end
	return handle[1], handle[2]
end

----
-- Locals
----

function SiftUp(heap, ind)
	local fnIsGreater = heap.fnIsGreater
	while true do
		if ind == 1 then
			return heap[1]
		end
		local current = heap[ind]
		local parentInd = math.floor(ind / 2)
		local parent = heap[parentInd]
		if fnIsGreater(current[2], parent[2]) then
			heap[ind] = parent
			parent[3] = ind
			heap[parentInd] = current
			current[3] = parentInd
			ind = parentInd
		else
			return current
		end
	end
end

function SiftDown(heap, ind)
	local heapLength = #heap
	local fnIsGreater = heap.fnIsGreater
	while true do
		local leftChildInd = 2 * ind
		local rightChildInd = leftChildInd + 1
		local swapInd = ind
		if leftChildInd <= heapLength and fnIsGreater(heap[leftChildInd][2], heap[swapInd][2]) then
			swapInd = leftChildInd
		end
		if rightChildInd <= heapLength and fnIsGreater(heap[rightChildInd][2], heap[swapInd][2]) then
			swapInd = rightChildInd
		end
		if swapInd ~= ind then
			local current = heap[ind]
			local swap = heap[swapInd]
			heap[ind] = swap
			swap[3] = ind
			heap[swapInd] = current
			current[3] = swapInd
			ind = swapInd
		else
			return heap[ind]
		end
	end
end

function CheckConsistency(heap)
	local len = #heap
	local fnIsGreater = heap.fnIsGreater
	for i = 1, len do
		local current = heap[i]
		if current[3] ~= i then
			return false
		end
		local leftInd = 2 * i
		local rightInd = leftInd + 1
		if leftInd <= len then
			local currentVal = current[2]
			local leftVal = heap[leftInd][2]
			if currentVal ~= leftVal and not fnIsGreater(currentVal, leftVal) then
				return false
			end
		end
		if rightInd <= len then
			local currentVal = current[2]
			local rightVal = heap[rightInd][2]
			if currentVal ~= rightVal and not fnIsGreater(currentVal, rightVal) then
				return false
			end
		end
	end
	return true
end

return Heap

-- do 
-- 	math.randomseed(os.clock())
-- 	local Heap = Heap
-- 	local h = Heap.New(function(a, b) return a < b end)

-- 	print("--- done 1 " .. os.clock())

-- 	for i = 1, 30000 do
-- 		local el = math.random()
-- 		Heap.Push(h, i, el)
-- 		-- assert(CheckConsistency(h))
-- 	end
-- 	assert(CheckConsistency(h))
-- 	print("--- done 2 " .. os.clock())

-- 	while not Heap.IsEmpty(h) do
-- 		local handle = h[1 + math.floor(math.random() * (#h - 1))]
-- 		Heap.Del(h, handle)
-- 		-- assert(CheckConsistency(h))
-- 	end
	
-- 	print("--- done 3 " .. os.clock())

-- 	local prev
-- 	while true do
-- 		local el, val = Heap.Pop(h)
-- 		if not el then
-- 			break
-- 		end
-- 		assert(CheckConsistency(h))
-- 		assert(not prev or prev == val or h.fnIsGreater(prev, val))
-- 		prev = val
-- 	end

-- 	print("--- done 4 " .. os.clock())
-- end
