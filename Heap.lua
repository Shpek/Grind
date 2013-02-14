-- Exported stuff goes here
HeapExports = {}

-- Declarations of local functions
local SiftUp, SiftDown, CheckConsistency

----
-- Exports
----

function HeapExports.New(fnIsGreater)
	if not fnIsGreater then
		fnIsGreater = function(a, b) return a > b end
	end
	return { fnIsGreater = fnIsGreater, }
end

function HeapExports.Push(heap, el, val)
	table.insert(heap, { el, val })
	return SiftUp(heap, #heap)
end

function HeapExports.IsEmpty(heap)
	return #heap == 0
end

function HeapExports.Pop(heap, ind)
	local numEls = #heap
	if numEls == 0 then
		return nil
	end
	local el = heap[1]
	heap[1] = heap[numEls]
	heap[numEls] = nil
	SiftDown(heap, 1)
	return el[1], el[2]
end

function HeapExports.Peek(heap)
	if #heap == 0 then
		return nil
	end
	local el = heap[1]
	return el[1], el[2]
end

function HeapExports.Del(heap, ind)
	local numEls = #heap
	if 1 > ind or ind > numEls then
		return nil
	end
	local el = heap[ind]
	heap[ind] = heap[numEls]
	heap[numEls] = nil
	if numEls > 1 then
		ind = SiftUp(heap, ind)
		SiftDown(heap, ind)
	end
	return el[1], el[2]
end

----
-- Locals
----

function SiftUp(heap, ind)
	if 0 > ind or ind > #heap then
		return nil
	end
	while true do
		if ind == 1 then
			return 1
		end
		local current = heap[ind]
		local parentInd = math.floor(ind / 2)
		local parent = heap[parentInd]
		if heap.fnIsGreater(current[2], parent[2]) then
			heap[ind] = parent
			heap[parentInd] = current
			ind = parentInd
		else
			return ind
		end
	end
end

function SiftDown(heap, ind)
	local heapLength = #heap
	while true do
		local leftChildInd = 2 * ind
		local rightChildInd = 2 * ind + 1
		local swapInd = ind
		if leftChildInd <= heapLength and heap.fnIsGreater(heap[leftChildInd][2], heap[swapInd][2]) then
			swapInd = leftChildInd
		end
		if rightChildInd <= heapLength and heap.fnIsGreater(heap[rightChildInd][2], heap[swapInd][2]) then
			swapInd = rightChildInd
		end
		if swapInd ~= ind then
			local current = heap[ind]
			heap[ind] = heap[swapInd]
			heap[swapInd] = current
			ind = swapInd
		else
			return ind
		end
	end
end

function CheckConsistency(heap)
	local len = #heap
	for i = 1, len do
		local current = heap[i]
		local leftInd = 2 * i
		local rightInd = 2 * i + 1
		if leftInd <= len then
			local currentVal = current[2]
			local leftVal = heap[leftInd][2]
			if currentVal ~= leftVal and not heap.fnIsGreater(currentVal, leftVal) then
				return false
			end
		end
		if rightInd <= len then
			local currentVal = current[2]
			local rightVal = heap[rightInd][2]
			if currentVal ~= rightVal and not heap.fnIsGreater(currentVal, rightVal) then
				return false
			end
		end
	end
	return true
end

-- return HeapExports

do 
	local Heap = HeapExports
	local h = Heap.New(function(a, b) return a < b end)

	print("--- done 1 " .. os.clock())
	math.randomseed(os.clock())

	for i = 1, 30000 do
		local el = math.random()
		Heap.Push(h, i, el)
	end

	assert(CheckConsistency(h))
	while not Heap.IsEmpty(h) do
		local ind = 1 + math.floor(math.random() * (#h - 1))
		Heap.Del(h, ind)
	end
	
	print("--- done 2 " .. os.clock())

	local prev
	while true do
		local el, val = Heap.Pop(h)
		if not el then
			break
		end
		assert(not prev or prev == val or h.fnIsGreater(prev, val))
		prev = val
	end

	print("--- done 3 " .. os.clock())
end