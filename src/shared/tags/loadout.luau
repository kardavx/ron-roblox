local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SignalBag = require(ReplicatedStorage.Shared.module.SignalBag)
local createInstance = require(ReplicatedStorage.Shared.util.createInstance)
local Maid = require(ReplicatedStorage.package.Maid)
return {
	tagName = "loadout",
	--- Zwraca instancje do janitora
	onInstanceAdded = function(instance: Instance): () -> ()
		local janitor = Maid.new()

		local prompt = createInstance("ProximityPrompt", {
			ObjectText = "DEBUG",
			ActionText = "Refresh Loadout",
			Parent = instance,
		}) :: ProximityPrompt

		janitor:GiveTask(prompt)
		janitor:GiveTask(prompt.Triggered:Connect(function()
			print("firing")
			SignalBag:Fire("ApplyLoadout")
		end))

		return function()
			janitor:Destroy()
			janitor = nil
		end
	end,
}
