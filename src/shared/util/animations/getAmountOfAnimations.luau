local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponConfigTypes = require(ReplicatedStorage.Shared.types.WeaponConfigTypes)
local function getAmountOfAnimations(
	animationsTable: { [WeaponConfigTypes.AnimationsUnion]: { number } | number }
): number
	local amount = 0

	for _, animationTrackOrTracks in animationsTable do
		if type(animationTrackOrTracks) == "table" then
			amount += #animationTrackOrTracks
		else
			amount += 1
		end
	end

	return amount
end

return getAmountOfAnimations
