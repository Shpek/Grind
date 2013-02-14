Queue = {}

function Queue.New()
	return { first = 0, last = -1 }
end

function Queue.PushFront(queue, val)
	local first = queue.first - 1
	queue.first = first
	queue[first] = val
end

function Queue.PushBack(queue, val)
	local last = queue.last + 1
	queue.last = last
	queue[last] = val
end

function Queue.PopFront(queue)
	local first = queue.first
	if first > queue.last then
		error("PopFront called on empty queue")
	end
	local val = queue[first]
	queue[first] = nil
	queue.first = first + 1
	return val
end

function Queue.PopBack(queue)
	local last = queue.last
	if queue.first > last then
		error("PopBack called on empty queue")
	end
	local val = queue[last]
	queue[last] = nil
	queue.last = last - 1
	return val
end

function Queue.IsEmpty(queue)
	return queue.first > queue.last
end

return Queue
