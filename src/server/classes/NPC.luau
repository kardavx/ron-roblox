local ReflectionService = game:GetService("ReflectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local NpcConfigs = ServerScriptService.configurations.npcs
local Animator = require(ReplicatedStorage.Shared.classes.Animator)
local PathFinder = require(ReplicatedStorage.Shared.classes.PathFinder)

local prefabs = ReplicatedStorage:WaitForChild("Prefabs")

local NPC = {}
local NPCs = {}
NPC.__index = NPC

function NPC.new(className: string, intimidation: number | nil, aggressiveness: number | nil)
	local self = setmetatable({}, NPC)
	self.className = className
	self.intimidation = intimidation or math.random()
	self.aggressiveness = aggressiveness or math.random()
	self.state = "Idle"

	self.connections = {}

	table.insert(NPCs, self)
	return self
end

function NPC:MoveTo(destination: Vector3): ()
	if self.connections.pathReached then
		self.connections.pathReached:Disconnect()
	end
	self.pathFinder:SetGoal(destination)

	self.connections.pathReached = self.pathFinder.events.moveToFinished.Event:Once(function()
		print("move to finished")
		self:SetState("Idle")
	end)

	return
end

function NPC:CreateCharacterModel(modelName: string): Model | nil
	local characterModel = prefabs.Characters:FindFirstChild(modelName)
	return characterModel and characterModel:Clone() or nil
end

function NPC:PlayAnimation(name: string): boolean
	if self.lastAnimationTracks then
		for _, animationTrack in self.lastAnimationTracks do
			animationTrack:Stop(0.25)
		end
	end

	local animationTracks = self.animator:GetAnimationTrack(name)

	if not animationTracks then
		return false
	end

	animationTracks[math.random(#animationTracks)]:Play(0.25)
	self.lastAnimationTracks = animationTracks
	return true
end

function NPC:SetState(state: string): boolean
	if self.state == state then
		return false
	end

	local oldState = self.state

	self:PlayAnimation(state)

	self.state = state
	return true
end

function NPC:Spawn(modelName: string, spawnCFrame: CFrame): ()
	self.character = self:CreateCharacterModel(modelName)
	self.character.Parent = workspace
	self.config = require(NpcConfigs[self.className])[modelName]
	self.animator = Animator.new(self.character.Humanoid)
	self.animator:LoadAnimations(self.config.animationsInfo)

	self.character:PivotTo(spawnCFrame)

	self.pathFinder = PathFinder.new(self.character)
end

function NPC:Destroy(): ()
	table.remove(NPCs, table.find(NPCs, self))
end

return NPC
