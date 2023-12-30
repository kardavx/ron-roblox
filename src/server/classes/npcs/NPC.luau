local ReflectionService = game:GetService("ReflectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local NpcConfigs = ServerScriptService.configurations.npcs
local ServerPlayerData = require(ServerScriptService.module.ServerPlayerData)
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
		local state = self:GetState()
		if state == "Run" or state == "Walk" then
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

function NPC:SetAttribute(name: string, value: any)
	self[name] = value

	if self.character then
		self.character:SetAttribute(name, value)
	end
end

function NPC:GetAttribute(name: string)
	return self[name]
end

function NPC:SetState(state: string): boolean
	if self:GetAttribute("State") == state then
		return false
	end

	local oldState = self.state

	self:PlayStateAnimation(state)
	self:SetAttribute("State", state)

	return true
end

function NPC:GetState()
	return self:GetAttribute("State")
end

function NPC:IsMoving(): boolean
	local state = self:GetAttribute("State")
	return state == "Run" or state == "Walk"
end

function NPC:StopMoving()
	if self:IsMoving() then
		self.pathFinder:MoveToFinished()
	end
end

function NPC:HandsUp(): boolean
	if self:GetAttribute("AreHandsUp") then
		return false
	end

	self:SetAttribute("AreHandsUp", true)
	self:PlayAnimation("HandsUp")
	return true
end

function NPC:HandsDown(): boolean
	if not self:GetAttribute("AreHandsUp") then
		return false
	end

	self:SetAttribute("AreHandsUp", false)
	self:StopAnimation("HandsUp")
	return true
end

function NPC:OnKnees()
	if self:GetAttribute("IsOnKnees") then
		return
	end

	self:StopMoving()

	self:SetAttribute("IsOnKnees", true)
	self:PlayAnimation("OnKnees")
end

function NPC:OffKnees()
	if not self:GetAttribute("IsOnKnees") then
		return
	end

	self:SetAttribute("IsOnKnees", false)
	self:StopAnimation("OnKnees")
end

function NPC:Surrender()
	self:StopMoving()
	return self:HandsUp()
end

function NPC:ScreamOn()
	if not self:GetAttribute("AreHandsUp") then
		self:StopMoving()
		return self:HandsUp()
	end

	return self:OnKnees()
end

function NPC:Arrest(player: Player): boolean
	if self:GetAttribute("IsArrested") then
		return false
	end

	local playerCharacter = player.Character
	local playerHumanoid = playerCharacter and playerCharacter:FindFirstChildWhichIsA("Humanoid")
	local playerAnimator = playerHumanoid and playerHumanoid:FindFirstChildWhichIsA("Animator")
	local playerHRP = playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart")
	local playerData = ServerPlayerData.GetPlayerProfile(player)

	playerData.producer.addWeaponHider("Arresting")

	if not playerAnimator or not playerHRP then
		return false
	end

	local hrp = self:GetPart("HumanoidRootPart")
	if not hrp then
		return false
	end

	self:SetAttribute("IsArrested", true)

	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://15786953347"
	local animationTrack = playerAnimator:LoadAnimation(animation)

	hrp.Anchored = true
	playerHRP.Anchored = true
	local playerPivot = playerCharacter:GetPivot()

	self.character:PivotTo(playerPivot + playerPivot.LookVector * 2)

	animationTrack.Stopped:Once(function()
		playerHRP.Anchored = false
		playerData.producer.removeWeaponHider("Arresting")
	end)

	self:PlayAnimation("Arrest")
	animationTrack:Play()
	return true
end

function NPC:GetCharacter(): Model | nil
	return self.character
end

function NPC:IsInFov(position: Vector3)
	local pivot = self:GetPivot("Head")
	if not pivot then
		return false
	end

	local direction = (position - pivot.Position).Unit

	return direction:Dot(pivot.LookVector) >= 0.5
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

function NPC:GetPivot(partName: string | nil)
	if not self.character then
		return
	end

	local part = partName and self.character:FindFirstChild(partName)

	return part and part:GetPivot() or self.character:GetPivot()
end

function NPC:GetPart(partName: string | nil): Instance | nil
	return self.character and self.character:FindFirstChild(partName)
end

function NPC:IsSurrended()
	return self:GetAttribute("AreHandsUp") and self:GetAttribute("IsOnKnees")
end

function NPC:Destroy(): ()
	table.remove(NPCs, table.find(NPCs, self))
end

return NPC
