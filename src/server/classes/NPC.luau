local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local NpcConfigs = ServerScriptService.configurations.npcs
local Animator = require(ReplicatedStorage.Shared.classes.Animator)

local prefabs = ReplicatedStorage:WaitForChild("Prefabs")

local NPC = {}
NPC.__index = NPC

function NPC.new(className: string, intimidation: number | nil, aggressiveness: number | nil)
	local self = setmetatable({}, NPC)
	self.className = className
	self.intimidation = intimidation or math.random()
	self.aggressiveness = aggressiveness or math.random()

	return self
end

function NPC:CreateCharacterModel(modelName: string): Model | nil
	local characterModel = prefabs.Characters:FindFirstChild(modelName)
	return characterModel and characterModel:Clone() or nil
end

function NPC:Spawn(modelName: string, spawnCFrame: CFrame): ()
	self.character = self:CreateCharacterModel(modelName)
	self.character.Parent = workspace
	self.config = require(NpcConfigs[self.className])[modelName]
	self.animator = Animator.new(self.character.Humanoid)
	self.animator:LoadAnimations(self.config.animationsInfo)

	self.animator.animationTracks.Idle[1]:Play()

	self.character:PivotTo(spawnCFrame)
end

function NPC:Destroy(): () end

return NPC
