local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local SignalBag = require(ReplicatedStorage.Shared.module.SignalBag)
local createInstance = require(ReplicatedStorage.Shared.util.createInstance)
local lerpNumber = require(ReplicatedStorage.Shared.util.lerpNumber)
local Maid = require(ReplicatedStorage.package.Maid)

local openAngle = -90

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

		local basePivot = instance:GetPivot()
		local currentRotation = 0
		local targetRotation = 0

		local prompt = createInstance("ProximityPrompt", {
			ActionText = "Door",
			ObjectText = "Open",
			Parent = instance,
		}) :: ProximityPrompt

		local sound = createInstance("Sound", {
			SoundId = "rbxassetid://192416578",
			Parent = hinge,
		})

		prompt.Triggered:Connect(function()
			local isOpened = targetRotation == openAngle

			sound:Play()
			SignalBag:Fire("Use")
			targetRotation = isOpened and 0 or openAngle
		end)

		doorJanitor:GiveTask(RunService.RenderStepped:Connect(function(deltaTime: number)
			currentRotation = lerpNumber(currentRotation, targetRotation, 6 * deltaTime)

			instance:PivotTo(basePivot * CFrame.Angles(0, math.rad(currentRotation), 0))
		end))

		doorJanitor:GiveTask(sound)
		doorJanitor:GiveTask(prompt)

		return function()
			doorJanitor:Destroy()
			doorJanitor = nil
		end
	end,
}
