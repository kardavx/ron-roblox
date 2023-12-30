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

		local doorJanitor = Maid.new()

		instance:SetAttribute("targetRotation", 0)
		instance:SetAttribute("lerpSpeed", 0)

		local doorKicked = false
		local doorLocked = randomBoolean()

		local openContainer = instance:FindFirstChild("Open")
		local peekContainer = instance:FindFirstChild("Peek")
		local kickContainer = instance:FindFirstChild("Kick")

		local peekPrompt
		local kickPrompt

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
				if doorLocked or doorKicked or not player.Character then
					return
				end

				sound:Play()
				instance:SetAttribute("lerpSpeed", openLerpSpeed)
				instance:SetAttribute(
					"targetRotation",
					isOpened(instance:GetAttribute("targetRotation")) and 0
						or getActualAngle(instance, player.Character, openAngle)
				)
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
				if doorLocked or doorKicked or not player.Character then
					return
				end

				local isPeeked = math.abs(instance:GetAttribute("targetRotation")) == peakAngle

				instance:SetAttribute("lerpSpeed", peekLerpSpeed)
				instance:SetAttribute(
					"targetRotation",
					isPeeked and 0 or getActualAngle(instance, player.Character, peakAngle)
				)
			end))

			doorJanitor:GiveTask(peekPrompt)
		end

		if kickContainer then
			local sound = createInstance("Sound", {
				SoundId = "rbxassetid://9116488438",
				Volume = 1.7,
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
				if doorKicked or not player.Character then
					return
				end

				doorKicked = true

				local playerData = ServerPlayerData.GetPlayerProfile(player)

				playerData.producer.addWeaponHider("KickingDoor")
				playerData.producer.addMouseLocker("KickingDoor")

				local playerCharacter = player.Character
				local playerHumanoid = playerCharacter and playerCharacter:FindFirstChildWhichIsA("Humanoid")
				local playerAnimator = playerHumanoid and playerHumanoid:FindFirstChildWhichIsA("Animator")

				playerCharacter.PrimaryPart.Anchored = true

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

					print(kickSucceeded)

					doorKicked = false
					playerCharacter.PrimaryPart.Anchored = false
					playerData.producer.removeWeaponHider("KickingDoor")
					playerData.producer.removeMouseLocker("KickingDoor")
					sound:Play()

					if kickSucceeded then
						if doorLocked then
							doorLocked = false
						end

						instance:SetAttribute("lerpSpeed", kickLerpSpeed)
						instance:SetAttribute("targetRotation", getActualAngle(instance, playerCharacter, kickAngle))
					end
				end)

				kickAnimationTrack.Stopped:Once(function()
					kickAnimationTrack:Destroy()
				end)
			end))

			doorJanitor:GiveTask(sound)
			doorJanitor:GiveTask(kickPrompt)
		end

		return function()
			doorJanitor:Destroy()
			doorJanitor = nil
		end
	end,
}