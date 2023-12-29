local function spawnWithParams<T>(func: (...T) -> (), ...: T)
	local params = { ... }
	task.spawn(function()
		func(table.unpack(params))
	end)
end

return spawnWithParams
