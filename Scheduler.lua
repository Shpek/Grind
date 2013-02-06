local Heap = require "Heap"
local Queue = require "Queue"

-- Exported stuff goes here
SchedulerExports = {}

-- Declarations of local functions
local Register

local SleepingThreads = Heap.New(function(a, b) return a < b end)
local NextFrameThreds = Queue.New()
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
	Queue.PushBack(NextFrameThreds, threadInfo)
	return thread
end

function Scheduler.Sleep(duration)
	coroutine.yield(duration or -1)
end

function Scheduler.Resume(thread)
end

function Scheduler.Terminate(thread)
	local threadInfo = ThreadsInfo[thread]
	if not threadInfo then
		error("Trying to terminate unknown thread")
	end
	if threadInfo.terminated then
		error("Trying to terminate thread more than once")
	end
	threadInfo.terminated = true
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
	while not Queue.IsEmpty(NextFrameThreds) do
		local threadInfo = Queue.PopFront(NextFrameThreds)
		ProcessThreadInfo(time, threadInfo)
	end
end

----
-- Locals
----

function ProcessThreadInfo(time, threadInfo)
	if threadInfo.terminated then
		ThreadsInfo[thread] = nil
		return
	end
	local success, sleepTime = coroutine.resume(threadInfo.thread)
	if not success then
		ThreadsInfo[thread] = nil
	elseif sleepTime == 0 then
		threadInfo.nextUpdateTime = 0
		Queue.PushBack(NextFrameThreds, threadInfo)
	elseif sleepTime > 0 then
		local nextUpdateTime = time + sleepTime
		threadInfo.nextUpdateTime = nextUpdateTime
		Heap.Push(SleepingThreads, threadInfo, nextUpdateTime)
	else
		threadInfo.nextUpdateTime = -1
	end
end

return SchedulerExports