local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local leanConfig = require(ReplicatedStorage.Shared.configurations.leanConfig)
local spawnWithParams = require(ReplicatedStorage.Shared.util.spawnWithParams)
type LocalProperties = {
	Update: (self: LocalProperties, deltaTime: number) -> (),
}

local Lean: LocalProperties = {} :: LocalProperties

local function ForEveryCharacter(func)
	local characters = {}

	for _, player in Players:GetPlayers() do
		if player.Character then
			spawnWithParams(func, player.Character)
		end
	end

	return characters
end

function Lean:Update(deltaTime)
	ForEveryCharacter(function(character: Model)
		local rootJoint = character:FindFirstChild("RootJoint", true)
		if not rootJoint then
			return
		end

		local leanFactor = character:GetAttribute("leanFactor")
		rootJoint.C0 = rootJoint.C0:Lerp(
			leanConfig.baseC0
				* CFrame.new((leanConfig.leanAngularAmount / 10) * leanFactor, 0, 0)
				* CFrame.Angles(0, math.rad(leanConfig.leanAngularAmount * leanFactor), 0),
			leanConfig.leanSpeed * deltaTime
		)
	end)
end

return Lean
