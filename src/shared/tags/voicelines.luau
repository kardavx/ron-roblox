local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local CurrentCamera = require(ReplicatedStorage.Shared.CurrentCamera)
local LocalPlayer = require(ReplicatedStorage.Shared.LocalPlayer)
local ClientPlayerData = require(ReplicatedStorage.Shared.module.ClientPlayerData)
local Maid = require(ReplicatedStorage.package.Maid)

local function onSoundPlayed(sound: Sound, dialogId: string)
	if not LocalPlayer.Character then
		return
	end

	if not sound.Parent then
		return
	end

	local distanceBetween: number
	if sound.Parent:IsA("BasePart") then
		distanceBetween = (CurrentCamera.CFrame.Position - sound.Parent.Position).Magnitude
	elseif sound.Parent:IsA("Attachment") then
		distanceBetween = (CurrentCamera.CFrame.Position - sound.Parent.WorldCFrame.Position).Magnitude
	elseif sound.Parent:IsA("Model") and sound.Parent.PrimaryPart then
		distanceBetween = (CurrentCamera.CFrame.Position - sound.Parent.PrimaryPart.Position).Magnitude
	elseif sound:IsDescendantOf(SoundService) or sound:IsDescendantOf(workspace) then
		distanceBetween = 0
	end

	if distanceBetween and distanceBetween <= sound.RollOffMaxDistance then
		ClientPlayerData.clientProducer.addDialog(dialogId)
	end
end

return {
	tagName = "voiceline",
	--- Zwraca instancje do janitora
	onInstanceAdded = function(instance: Sound): () -> ()
		local dialogId = instance:GetAttribute("dialogId")
		local janitor = Maid.new()

		print(instance)

		if instance.Playing then
			print(`{instance.Name} is playing`)
			onSoundPlayed(instance, dialogId)
		end

		janitor:GiveTask(instance.Played:Connect(function()
			print(`{instance.Name} has played`)
			onSoundPlayed(instance, dialogId)
		end))

		return function()
			janitor:Destroy()
			janitor = nil
		end
	end,
}
