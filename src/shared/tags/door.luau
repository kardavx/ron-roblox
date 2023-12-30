local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local lerpNumber = require(ReplicatedStorage.Shared.util.lerpNumber)
local Maid = require(ReplicatedStorage.package.Maid)

local openAngle = 90

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

		local doorJanitor = Maid.new()

		local basePivot = instance:GetPivot()
		local currentRotation = 0

		local peekContainer = instance:FindFirstChild("Peek")
		local kickContainer = instance:FindFirstChild("Kick")

		local peekPrompt
		local kickPrompt

		if peekContainer then
			peekPrompt = peekContainer:WaitForChild("ProximityPrompt") :: ProximityPrompt
		end

		if kickContainer then
			kickPrompt = kickContainer:WaitForChild("ProximityPrompt") :: ProximityPrompt
		end

		doorJanitor:GiveTask(RunService.RenderStepped:Connect(function(deltaTime: number)
			local isOpened = isOpened(instance:GetAttribute("targetRotation"))

			if peekPrompt then
				peekPrompt.Enabled = not isOpened
			end

			if kickPrompt then
				kickPrompt.Enabled = not isOpened
			end

			currentRotation = lerpNumber(
				currentRotation,
				instance:GetAttribute("targetRotation"),
				instance:GetAttribute("lerpSpeed") * deltaTime
			)
			instance:PivotTo(basePivot * CFrame.Angles(0, math.rad(currentRotation), 0))
		end))

		return function()
			doorJanitor:Destroy()
			doorJanitor = nil
		end
	end,
}
