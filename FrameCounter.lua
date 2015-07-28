local FrameCounter = {}

local SamplesCount = 1024
local CurInd = 1
local FrameTimes = {}

function FrameCounter.Update(frameTime)
	FrameTimes[CurInd] = frameTime
	CurInd = CurInd + 1
	if CurInd > SamplesCount then
		CurInd = 1
	end
end

function FrameCounter.GetSamplesCount()
	return #FrameTimes
end

function FrameCounter.GetFrameTimes()
	if #FrameTimes < SamplesCount then
		local cur = 1
		return function()
			local ret = FrameTimes[cur]
			cur = cur + 1
			return ret
		end
	else
		local cur = CurInd
		local el = 1
		return function()
			local ret = FrameTimes[cur]
			cur = cur + 1
			if cur > SamplesCount then
				cur = 1
			end
		end
	end
end

return FrameCounterv