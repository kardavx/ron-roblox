local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ServerPlayerData = require(ServerScriptService.module.ServerPlayerData)
local GameTypes = require(ReplicatedStorage.Shared.types.GameTypes)
local Maid = require(ReplicatedStorage.package.Maid)

export type Class = {
	__index: Class,
	new: (player: Player, data: ServerPlayerData.ServerPlayerProfile) -> Object,
	Update: (self: Object, deltaTime: number) -> (),
	Destroy: (self: Object) -> (),
} & GameTypes.ServerMethods<Object>

export type Object = typeof(setmetatable(
	{} :: {
		characterJanitor: Maid.Maid,
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

	self.characterJanitor = Maid.new()
	self.data = data
	self.player = player
	self.currentLean = 0

	print("constructed")

	self.data.producer:subscribe(function(state)
		return state.leanFactor
	end, function(newValue: number)
		if self.player.Character then
			print("value changed")
			self.player.Character:SetAttribute("leanFactor", newValue)
		end
	end)

	self.characterJanitor:GiveTask(self.player.CharacterAdded:Connect(function(character: Model)
		print("character added")
		character:SetAttribute("leanFactor", self.data.producer:getState().leanFactor)
	end))

	if self.player.Character then
		print("character here")
		self.player.Character:SetAttribute("leanFactor", self.data.producer:getState().leanFactor)
	end

	return self
end

function Lean:Destroy()
	self.characterJanitor:Destroy()
end

return Lean
