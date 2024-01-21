local ReplicatedStorage = game:GetService("ReplicatedStorage")

local spawnWithParams = require(ReplicatedStorage.Shared.util.spawnWithParams)

local function spawnMultipleWithParams<P>(elements: { [number]: { (...P) -> () | { P } } })
	for _, element in elements do
		spawnWithParams(element[1], table.unpack(element[2]))
	end
end

return spawnMultipleWithParams
