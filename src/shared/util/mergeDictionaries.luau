local ReplicatedStorage = game:GetService("ReplicatedStorage")

local deepClone = require(ReplicatedStorage.Shared.util.deepClone)
type Dictionary = { [string]: unknown }

local function mergeDictionaries<T1, T2>(dictionaryA: T1 & Dictionary, dictionaryB: T2 & Dictionary): T1 & T2
	local merged = deepClone(dictionaryA)

	for key, value in pairs(deepClone(dictionaryB)) do
		merged[key] = value
	end

	return merged :: T1 & T2
end

return mergeDictionaries
