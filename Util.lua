function TableToString(tbl, depth)
	if depth == nil then
		depth = 0
	end
	local dumpStr = "{ "
	for k, v in pairs(tbl) do
		if type(v) == "table" and depth > 0 then
			dumpStr = dumpStr .. tostring(k) .. " = " .. TableToString(v, depth - 1) .. " "	
		else
			dumpStr = dumpStr .. tostring(k) .. " = " .. tostring(v) .. " "	
		end
	end
	return dumpStr .. "}"
end
