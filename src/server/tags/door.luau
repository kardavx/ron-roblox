local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local promptConfig = require(ReplicatedStorage.Shared.configurations.promptConfig)
local ServerPlayerData = require(ServerScriptService.module.ServerPlayerData)
local createInstance = require(ReplicatedStorage.Shared.util.createInstance)
local randomBoolean = require(ReplicatedStorage.Shared.util.randomBoolean)
local Maid = require(ReplicatedStorage.package.Maid)

local openAngle = 90
local peakAngle = 15
local kickAngle = 110

local peekLerpSpeed = 4
local openLerpSpeed = 6
local kickLerpSpeed = 12

local promptsDistance = 6

local function AngleBetween(vectorA, vectorB)
	return math.acos(math.clamp(vectorA:Dot(vectorB), -1, 1))
end

local function getActualAngle(door: Model, opener: Model, angle: number)
	if not opener.PrimaryPart or not door.PrimaryPart then
		return
	end

	local lookForward = door.PrimaryPart.CFrame.LookVector
	local lookToPoint = (opener.PrimaryPart.CFrame.Position - door.PrimaryPart.CFrame.Position).Unit
	local angleDoorCharacter = AngleBetween(lookForward, lookToPoint)

	if math.abs(math.deg(angleDoorCharacter)) > 100 then
		return -angle
	else
		return angle
	end
end

local function isOpened(targetRotation: number): boolean
	return math.abs(targetRotation) >= openAngle
end

return {
	tagName = "door",
	--- Zwraca instancje do janitora
	onInstanceAdded = function(instance: Model): () -> ()
		if not instance.PrimaryPart then
			repeat
				task.wait()
			until instance.PrimaryPart
		end

		local hinge = instance.PrimaryPart
		local basePivot = instance:GetPivot()

		local doorJanitor = Maid.new()

		instance:SetAttribute("targetRotation", 0)
		instance:SetAttribute("lerpSpeed", 0)

		local doorKicked = false
		local doorLocked = randomBoolean()

		local openContainer = instance:FindFirstChild("Open")
		local peekContainer = instance:FindFirstChild("Peek")
		local kickContainer = instance:FindFirstChild("Kick")
		local doorContainer = instance:FindFirstChild("Door")
		local pathfindingModifier = instance:FindFirstChildWhichIsA("PathfindingModifier", true)

		local peekPrompt
		local kickPrompt

		local function openDoor(sound: Sound, character: Model?)
			if doorLocked or doorKicked or not character then
				return
			end

			sound:Play()
			instance:SetAttribute("lerpSpeed", openLerpSpeed)
			instance:SetAttribute(
				"targetRotation",
				isOpened(instance:GetAttribute("targetRotation")) and 0
					or getActualAngle(instance, character, openAngle)
			)
		end

		local function peekDoor(character: Model?)
			if doorLocked or doorKicked or not character then
				return
			end

			local isPeeked = math.abs(instance:GetAttribute("targetRotation")) == peakAngle

			instance:SetAttribute("lerpSpeed", peekLerpSpeed)
			instance:SetAttribute("targetRotation", isPeeked and 0 or getActualAngle(instance, character, peakAngle))
		end

		local function kickDoor(sound: Sound, soundBreached: Sound, onKicked: () -> (), character: Model?)
			if doorKicked or not character or not character.PrimaryPart then
				onKicked()
				return
			end

			doorKicked = true

			local playerHumanoid = character and character:FindFirstChildWhichIsA("Humanoid")
			local playerAnimator = playerHumanoid and playerHumanoid:FindFirstChildWhichIsA("Animator")

			character.PrimaryPart.Anchored = true

			local kickAnimation = Instance.new("Animation")
			kickAnimation.AnimationId = "rbxassetid://15807161539"
			local kickAnimationTrack = playerAnimator:LoadAnimation(kickAnimation)
			kickAnimation:Destroy()

			repeat
				task.wait()
			until kickAnimationTrack.Length > 0

			kickAnimationTrack:Play()
			task.delay(kickAnimationTrack.Length, function()
				local kickSucceeded = (doorLocked == false) and true or randomBoolean(3)

				doorKicked = false
				character.PrimaryPart.Anchored = false
				onKicked()
				sound:Play()

				if kickSucceeded then
					if doorLocked then
						doorLocked = false
					end

					soundBreached:Play()
					instance:SetAttribute("lerpSpeed", kickLerpSpeed)
					instance:SetAttribute("targetRotation", getActualAngle(instance, character, kickAngle))
				end
			end)

			kickAnimationTrack.Stopped:Once(function()
				kickAnimationTrack:Destroy()
			end)
		end

		if openContainer then
			local openPrompt = createInstance("ProximityPrompt", {
				ActionText = "Open",
				ObjectText = "Door",
				RequiresLineOfSight = false,
				KeyboardKeyCode = promptConfig.defaultInteractionKey,
				MaxActivationDistance = promptsDistance,
				Parent = openContainer,
			}) :: ProximityPrompt

			local sound = createInstance("Sound", {
				SoundId = "rbxassetid://192416578",
				Parent = hinge,
			})

			doorJanitor:GiveTask(openPrompt.Triggered:Connect(function(player: Player)
				openDoor(sound, player.Character)
			end))

			doorJanitor:GiveTask(sound)
			doorJanitor:GiveTask(openPrompt)
		end

		if peekContainer then
			peekPrompt = createInstance("ProximityPrompt", {
				ActionText = "Peek",
				ObjectText = "Door",
				RequiresLineOfSight = false,
				KeyboardKeyCode = promptConfig.defaultInteractionKey,
				MaxActivationDistance = promptsDistance,
				Parent = peekContainer,
			}) :: ProximityPrompt

			doorJanitor:GiveTask(peekPrompt.Triggered:Connect(function(player: Player)
				peekDoor(player.Character)
			end))

			doorJanitor:GiveTask(peekPrompt)
		end

		if kickContainer then
			local sound = createInstance("Sound", {
				SoundId = "rbxassetid://9116488438",
				Volume = 1.7,
				Parent = hinge,
			})

			-- 9116546594
			local soundBreached = createInstance("Sound", {
				SoundId = "rbxassetid://9116546594",
				Volume = 1,
				Parent = hinge,
			})

			kickPrompt = createInstance("ProximityPrompt", {
				ActionText = "Kick",
				ObjectText = "Door",
				RequiresLineOfSight = false,
				KeyboardKeyCode = promptConfig.defaultInteractionKey,
				MaxActivationDistance = promptsDistance,
				Parent = kickContainer,
			}) :: ProximityPrompt

			doorJanitor:GiveTask(kickPrompt.Triggered:Connect(function(player: Player)
				local playerData = ServerPlayerData.GetPlayerProfile(player)
				playerData.producer.addWeaponHider("KickingDoor")
				playerData.producer.addMouseLocker("KickingDoor")

				kickDoor(sound, soundBreached, function()
					playerData.producer.removeWeaponHider("KickingDoor")
					playerData.producer.removeMouseLocker("KickingDoor")
				end, player.Character)
			end))

			doorJanitor:GiveTask(sound)
			doorJanitor:GiveTask(kickPrompt)
			doorJanitor:GiveTask(soundBreached)
		end

		doorJanitor:GiveTask(instance:GetAttributeChangedSignal("targetRotation"):Connect(function()
			instance:PivotTo(basePivot * CFrame.Angles(0, math.rad(instance:GetAttribute("targetRotation")), 0))
		end))

		return function()
			doorJanitor:Destroy()
			doorJanitor = nil
		end
	end,
}
