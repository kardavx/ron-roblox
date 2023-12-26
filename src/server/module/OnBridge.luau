local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Bridgenet2 = require(ReplicatedStorage.package.Bridgenet2)

local bridges: { [string]: typeof(Bridgenet2.ServerBridge("")) } = {}

local function createIfMissing(bridgeName: string)
	if not bridges[bridgeName] then
		bridges[bridgeName] = Bridgenet2.ServerBridge(bridgeName)
	end
end

local function OnBridge(expectedPlayer: Player, bridgeName: string, onBridge: (...unknown) -> ())
	createIfMissing(bridgeName)
	local bridge = bridges[bridgeName]
	bridge:Connect(function(player: Player, ...)
		if player ~= expectedPlayer then
			return
		end

		onBridge(...)
	end)
end

return OnBridge
