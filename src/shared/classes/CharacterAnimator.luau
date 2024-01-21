local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animator = require(ReplicatedStorage.Shared.classes.Animator)
local CharacterAnimator = {}
CharacterAnimator.__index = CharacterAnimator

function CharacterAnimator:GetCharacterScale()
	return self.character:GetScale()
end

function CharacterAnimator:PlayAnimation(name: string)
	if self.lastAnimationTrack then
		self.lastAnimationTrack:Stop(0.25)
	end

	local animationTrack = self.animator:GetAnimationTrack(name)
	animationTrack:Play(0.25)

	self.lastAnimationTrack = animationTrack
end

function CharacterAnimator:GetCharacterSpeed()
	return self.character.PrimaryPart.AssemblyLinearVelocity.Magnitude
end

function CharacterAnimator:OnRunning()
	local speed = self:GetCharacterSpeed()
	print(speed)
	if speed >= 12 then
		self.pose = "Running"
		self.animator.animationTracks.Run[1]:Play()
	elseif speed >= 0.1 then
		self.pose = "Walking"
		self.animator.animationTracks.Walk[1]:Play()
	else
		self.pose = "Idle"
		self.animator.animationTracks.Idle[1]:Play()
	end
end

function CharacterAnimator.new(character: Model, config)
	local self = setmetatable({}, CharacterAnimator)
	self.character = character
	self.humanoid = self.character:FindFirstChildOfClass("Humanoid")
	self.pose = "Idle"
	self.config = config
	self.animator = Animator.new(self.humanoid)
	self.animator:LoadAnimations(self.config.animationsInfo)

	self.connections = {}

	self.connections.running = self.humanoid.Running:Once(function(...)
		self:OnRunning(...)
	end)

	self.connections.velocityChange = self.character.PrimaryPart:GetPropertyChangedSignal("Velocity"):Connect(function()
		local speed = self:GetCharacterSpeed()
		print(speed)
	end)

	self.connections.died = self.humanoid.Died:Once(function() end)

	self:OnRunning(0)

	return self
end

function CharacterAnimator:Destroy() end

return CharacterAnimator
