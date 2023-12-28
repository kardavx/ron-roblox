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
	self:SetState("Run")

	self.connections.pathReached = self.pathFinder.events.moveToFinished.Event:Once(function()
		if self.state == "Run" or self.state == "Walk" then
			self:SetState("Idle")
		end
	end)

	return
end

function NPC:CreateCharacterModel(modelName: string): Model | nil
	local characterModel = prefabs.Characters:FindFirstChild(modelName)
	return characterModel and characterModel:Clone() or nil
end

function NPC:PlayStateAnimation(name): boolean
	if self.lastAnimationTracks then
		for _, animationTrack in self.lastAnimationTracks do
			animationTrack:Stop(0.5)
		end
	end

	self.lastAnimationTracks = self:PlayAnimation(name)
	return true
end

function NPC:PlayAnimation(name: string)
	local animationTracks = self.animator:GetAnimationTrack(name)

	if not animationTracks then
		return
	end

	local animationTrack = animationTracks[math.random(#animationTracks)]
	animationTrack:Play(0.5)

	animationTrack:GetMarkerReachedSignal("LoopMeta"):Connect(function()
		animationTrack.TimePosition = animationTrack:GetTimeOfKeyframe("LoopStart")
	end)

	return animationTracks
end

function NPC:StopAnimation(name: string): boolean
	for _, animationTrack in self.animationTracks[name] do
		animationTrack:Stop(0.5)
	end

	return true
end

function NPC:SetState(state: string): boolean
	if self.state == state then
		return false
	end

	local oldState = self.state

	self:PlayStateAnimation(state)

	self.state = state
	return true
end

function NPC:IsMoving(): boolean
	return self.state == "Run" or self.state == "Walk"
end

function NPC:StopMoving()
	if self:IsMoving() then
		self.pathFinder:MoveToFinished()
	end
end

function NPC:HandsUp()
	if self.areHandsUp then
		return
	end

	self.areHandsUp = true
	self:PlayAnimation("HandsUp")
end

function NPC:HandsDown()
	if not self.areHandsUp then
		return
	end

	self.areHandsUp = false
	self:StopAnimation("HandsUp")
end

function NPC:OnKnees()
	if self.isOnKnees then
		return
	end

	self:StopMoving()

	self.isOnKnees = true
	self:PlayAnimation("OnKnees")
end

function NPC:OffKnees()
	if not self.isOnKnees then
		return
	end

	self.isOnKnees = false
	self:StopAnimation("OnKnees")
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
