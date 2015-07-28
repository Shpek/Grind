local Heap = require "Heap"
local Queue = require "Queue"

-- Exported stuff goes here
local Scheduler = {}

-- Declarations of local functions
local ProcessThreadInfo

-- State
local SleepingThreads = Heap.New(function(a, b) return a < b end)
local NextFrameThreads = Queue.New()
local UpdatedThisFrameNextFrameThreads = Queue.New()
local ThreadsInfo = {}

----
-- Exports
----

function Scheduler.Init()
end

function Scheduler.Done()
end

function Scheduler.NewThread(fn)
	local thread = coroutine.create(fn)
	local threadInfo = {
		thread = thread,
		nextUpdateTime = 0,
	}
	ThreadsInfo[thread] = threadInfo
	Queue.PushBack(NextFrameThreads, threadInfo)
	return thread
end

function Scheduler.Sleep(duration)
	assert(duration == nil or duration >= 0)
	coroutine.yield(duration or -1)
end

function Scheduler.Resume(thread)
	if coroutine.status(thread) == "dead" then
		error("Trying to resume terminated thread")
	end
	local threadInfo = ThreadsInfo[thread]
	if not threadInfo then
		error("Trying to resume unknown thread")
	end
	local nextUpdateTime = threadInfo.nextUpdateTime
	if nextUpdateTime == 0 then
		return
	elseif nextUpdateTime == -1 then
		Queue.PushBack(NextFrameThreads, threadInfo)
	else
		assert(threadInfo.heapHandle)
		local info = Heap.Del(SleepingThreads, threadInfo.heapHandle)
		assert(info == threadInfo)
		Queue.PushBack(NextFrameThreads, threadInfo)
	end
end

function Scheduler.Terminate(thread)
	if coroutine.status(thread) == "dead" then
		error("Trying to terminate terminated thread")
	end
	local threadInfo = ThreadsInfo[thread]
	if not threadInfo then
		error("Trying to terminate unknown thread")
	end
	threadInfo.terminated = true
	if threadInfo.nextUpdateTime <= 0 then
		-- If the thread is scheduled for the next farme (updateTime == 0)
		-- do nothing - it will be removed from the queue on the next update
		return
	end
	-- The thread is scheduled in the update heap
	local info = Heap.Del(SleepingThreads, threadInfo.heapHandle)
	assert(info == threadInfo)
	ThreadsInfo[thread] = nil
end

function Scheduler.Update(time)
	while true do
		local threadInfo = Heap.Peek(SleepingThreads)
		if not threadInfo then
			break
		end
		if threadInfo.terminated then
			ThreadsInfo[thread] = nil
			Heap.Pop(SleepingThreads)
		elseif threadInfo.nextUpdateTime > time then
			break
		else 
			Heap.Pop(SleepingThreads)
			ProcessThreadInfo(time, threadInfo)
		end
	end
	while not Queue.IsEmpty(NextFrameThreads) do
		local threadInfo = Queue.PopFront(NextFrameThreads)
		ProcessThreadInfo(time, threadInfo)
	end
	while not Queue.IsEmpty(UpdatedThisFrameNextFrameThreads) do
		Queue.PushBack(NextFrameThreads, Queue.PopFront(UpdatedThisFrameNextFrameThreads))
	end
end

----
-- Locals
----

function ProcessThreadInfo(time, threadInfo)
	if threadInfo.terminated then
		ThreadsInfo[threadInfo.thread] = nil
		return
	end
	local thread = threadInfo.thread
	local success, sleepTime = coroutine.resume(thread)
	if not success or coroutine.status(thread) == "dead" then
		ThreadsInfo[thread] = nil
	elseif sleepTime == 0 then
		threadInfo.nextUpdateTime = 0
		threadInfo.heapHandle = nil
		Queue.PushBack(UpdatedThisFrameNextFrameThreads, threadInfo)
	elseif sleepTime > 0 then
		local nextUpdateTime = time + sleepTime
		threadInfo.nextUpdateTime = nextUpdateTime
		threadInfo.heapHandle = Heap.Push(SleepingThreads, threadInfo, nextUpdateTime)
	else
		threadInfo.nextUpdateTime = -1
		threadInfo.heapHandle = nil
	end
end

return Scheduler

-- do
-- 	local S = Scheduler
-- 	local threads = {}
-- 	local inds = {}
-- 	for i = 1, 10 do
-- 		local thread = S.NewThread(function()
-- 			S.Sleep(1)
-- 			print("in " .. i)
-- 		end)
-- 		threads[i] = thread
-- 		inds[i] = i
-- 	end
-- 	S.Update(os.clock())
-- 	math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))

-- 	local curInd = 1
-- 	while curInd < #inds do
-- 		local rndInd = math.random(curInd + 1, #inds)
-- 		local rndEl = inds[rndInd]
-- 		inds[rndInd] = inds[curInd]
-- 		inds[curInd] = rndEl
-- 		curInd = curInd + 1
-- 	end

-- 	print("---")

-- 	for i = 1, 10 do
-- 		local rndInd = inds[i]
-- 		print(rndInd)
-- 		local th = threads[rndInd]
-- 		S.Resume(th)
-- 		S.Update(os.clock())
-- 	end
-- end
