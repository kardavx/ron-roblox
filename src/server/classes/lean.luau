local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local leanConfig = require(ReplicatedStorage.Shared.configurations.leanConfig)
local ServerPlayerData = require(ServerScriptService.module.ServerPlayerData)
local GameTypes = require(ReplicatedStorage.Shared.types.GameTypes)

export type Class = {
	__index: Class,
	new: (player: Player, data: ServerPlayerData.ServerPlayerProfile) -> Object,
	Update: (self: Object, deltaTime: number) -> (),
} & GameTypes.ServerMethods<Object>

export type Object = typeof(setmetatable(
	{} :: {
		data: ServerPlayerData.ServerPlayerProfile,
		player: Player,
		currentLean: number,
	},
	{} :: Class
))

local Lean: Class = {} :: Class
Lean.__index = Lean

function Lean.new(player: Player, data: ServerPlayerData.ServerPlayerProfile)
	local self = setmetatable({}, Lean)

	self.data = data
	self.player = player
	self.currentLean = 0

	return self
end

function Lean:Update(deltaTime: number)
	if not self.player.Character then
		return
	end

	local RootJoint = self.player.Character:FindFirstChild("RootJoint", true) :: Motor6D
	if not RootJoint then
		return
	end

	local factor = self.data.producer:getState().leanFactor
	RootJoint.C0 = RootJoint.C0:Lerp(
		leanConfig.baseC0
			* CFrame.new((leanConfig.leanAngularAmount / 10) * factor, 0, 0)
			* CFrame.Angles(0, math.rad(leanConfig.leanAngularAmount * factor), 0),
		leanConfig.leanSpeed * deltaTime
	)
end

return Lean
