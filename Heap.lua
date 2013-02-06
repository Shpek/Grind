-- Exported stuff goes here
HeapExports = {}

-- Declarations of local functions
local SiftUp, SiftDown

----
-- Exports
----

function HeapExports.New(pred)
	if not pred then
		pred = function(a, b) return a > b end
	end
	return { pred = pred, }
end

function HeapExports.Push(heap, el, val)
	table.insert(heap, { el, val })
	SiftUp(heap)
end

function HeapExports.Pop(heap)
	local numEls = #heap
	if numEls == 0 then
		return nil
	end
	local el = heap[1]
	heap[1] = heap[numEls]
	heap[numEls] = nil
	SiftDown(heap)
	return el[1], el[2]
end

function HeapExports.Peek(heap)
	if #heap == 0 then
		return nil
	end
	local el = heap[1]
	return el[1], el[2]
end

----
-- Locals
----

function SiftUp(heap)
	local ind = #heap
	if ind == 0 then
		return
	end
	while true do
		if ind == 1 then
			return
		end
		local current = heap[ind]
		local parentInd = math.floor(ind / 2)
		local parent = heap[parentInd]
		if heap.pred(current[2], parent[2]) then
			heap[ind] = parent
			heap[parentInd] = current
			ind = parentInd
		else
			return
		end
	end
end

function SiftDown(heap)
	local ind = 1
	local heapLength = #heap
	while true do
		local leftChildInd = 2 * ind
		local rightChildInd = 2 * ind + 1
		local swapInd = ind
		if leftChildInd <= heapLength and heap.pred(heap[leftChildInd][2], heap[swapInd][2]) then
			swapInd = leftChildInd
		end
		if rightChildInd <= heapLength and heap.pred(heap[rightChildInd][2], heap[swapInd][2]) then
			swapInd = rightChildInd
		end
		if swapInd ~= ind then
			local current = heap[ind]
			heap[ind] = heap[swapInd]
			heap[swapInd] = current
			ind = swapInd
		else
			return
		end
	end
end

return HeapExports

-- local h = HeapExports.Create(function(a, b) return a < b end)

-- print("--- done 1 " .. os.clock())

-- for i = 1, 3000 do
-- 	HeapExports.Push(h, i, math.random())
-- end

-- print("--- done 2 " .. os.clock())

-- local prev
-- while true do
-- 	local el, val = HeapExports.Pop(h)
-- 	if not el then
-- 		break
-- 	end
-- 	assert(not prev or val >= prev)
-- 	prev = val
-- end

-- print("--- done 3 " .. os.clock())
