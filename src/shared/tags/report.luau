local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TOC = require(ReplicatedStorage.Shared.module.TOC)
local createInstance = require(ReplicatedStorage.Shared.util.createInstance)
local Maid = require(ReplicatedStorage.package.Maid)

return {
	tagName = "report",
	--- Zwraca instancje do janitora
	onInstanceAdded = function(instance: Instance): () -> ()
		local janitor = Maid.new()

		local reportReason = instance:GetAttribute("reportReason")
		if not reportReason then
			reportReason = "sus"
		end

		local prompt = createInstance("ProximityPrompt", {
			ObjectText = "Report",
			ActionText = reportReason,
			RequiresLineOfSight = false,
			Parent = instance,
		}) :: ProximityPrompt

		janitor:GiveTask(prompt)
		janitor:GiveTask(prompt.Triggered:Connect(function()
			TOC:PlayVoiceline("Acknowledge")
		end))

		return function()
			janitor:Destroy()
			janitor = nil
		end
	end,
}
