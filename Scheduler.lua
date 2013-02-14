local Heap = require "Heap"
local Queue = require "Queue"

-- Exported stuff goes here
SchedulerExports = {}

-- Declarations of local functions
local ProcessThreadInfo

local SleepingThreads = Heap.New(function(a, b) return a < b end)
local NextFrameThreads = Queue.New()
local UpdatedThisFrameNextFrameThreads = Queue.New()
local ThreadsInfo = {}
----
-- Exports
----

function SchedulerExports.Init()
end

function SchedulerExports.Done()
end

function SchedulerExports.NewThread(fn)
	local thread = coroutine.create(fn)
	local threadInfo = {
		thread = thread,
		nextUpdateTime = 0,
	}
	ThreadsInfo[thread] = threadInfo
	Queue.PushBack(NextFrameThreads, threadInfo)
	return thread
end

function SchedulerExports.Sleep(duration)
	coroutine.yield(duration or -1)
end

function SchedulerExports.Resume(thread)
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
		local info = Heap.Del(h, threadInfo.heapIdx)
		assert(info == threadInfo)
		Queue.PushBack(NextFrameThreads, threadInfo)
	end
end

function SchedulerExports.Terminate(thread)
	local threadInfo = ThreadsInfo[thread]
	if not threadInfo then
		error("Trying to terminate unknown thread")
	end
	if threadInfo.terminated then
		error("Trying to terminate thread more than once")
	end
	threadInfo.terminated = true
	if threadInfo.nextUpdateTime <= 0 then
		-- If the thread is scheduled for the next frame (updateTime == 0)
		-- do nothing - it will be removed from the queue on the next update
		return
	end
	-- The thread is scheduled in the update heap
	local info = Heap.Del(h, threadInfo.heapIdx)
	assert(info == threadInfo)
end

function SchedulerExports.Update(time)
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
		Queue.PushBack(UpdatedThisFrameNextFrameThreads, threadInfo)
	elseif sleepTime > 0 then
		local nextUpdateTime = time + sleepTime
		threadInfo.nextUpdateTime = nextUpdateTime
		threadInfo.heapIdx = Heap.Push(SleepingThreads, threadInfo, nextUpdateTime)
	else
		threadInfo.nextUpdateTime = -1
	end
end

return SchedulerExports

-- do
-- 	local S = SchedulerExports
-- 	for i = 1, 100 do
-- 		S.NewThread(function()
-- 			while true do
-- 				S.Sleep(1)
-- 				print("---")
-- 			end
-- 		end)
-- 	end
-- 	for i = 1, 10000000 do
-- 		S.Update(os.clock())
-- 	end
-- end