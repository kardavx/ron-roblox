local function spawnWithParams<P>(func: (...P) -> (), ...: P)
	local params = { ... }
	task.spawn(function()
		func(table.unpack(params))
	end)
end

return spawnWithParams
