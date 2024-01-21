local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponConfigTypes = require(ReplicatedStorage.Shared.types.WeaponConfigTypes)
local configsDirectory = ReplicatedStorage.Shared.configurations.weapons

local function getConfigName(weaponName: string)
	return `{weaponName}Config`
end

local function findConfig(weaponName: string)
	local configImplementation = configsDirectory:FindFirstChild(getConfigName(weaponName)) :: ModuleScript
	if not configImplementation then
		error(`Couldn't find config for {weaponName}`)
	end

	local config = require(configImplementation) :: WeaponConfigTypes.Config
	return config
end

return findConfig
