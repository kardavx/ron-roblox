local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CurrentCamera = require(ReplicatedStorage.Shared.CurrentCamera)
local LocalPlayer = require(ReplicatedStorage.Shared.LocalPlayer)
local ClientPlayerData = require(ReplicatedStorage.Shared.module.ClientPlayerData)
local Gloves = require(ReplicatedStorage.Shared.module.Gloves)
local Watch = require(ReplicatedStorage.Shared.module.Watch)
local WeaponTypes = require(ReplicatedStorage.Shared.types.WeaponTypes)
local viewmodelsStorage = ReplicatedStorage.Viewmodels :: Folder

return function(viewmodelName: string): WeaponTypes.Viewmodel
	local desiredViewmodel = viewmodelsStorage:FindFirstChild(viewmodelName) :: WeaponTypes.Viewmodel
	if not desiredViewmodel then
		error(`Couldn't find viewmodel of name {viewmodelName}`)
	end

	local clonedViewmodel = desiredViewmodel:Clone()
	clonedViewmodel.Parent = CurrentCamera

	for _, descendant: Instance in clonedViewmodel:GetDescendants() do
		if not descendant:IsA("BasePart") then
			continue
		end

		print(`setting {descendant.Name}`)

		descendant.CollisionGroup = "viewmodel"
		descendant.CanCollide = false
		descendant.CanQuery = false
		descendant.CanTouch = false
	end

	if LocalPlayer.Character then
		print("Character is there")
		local BodyColors = LocalPlayer.Character:FindFirstChildOfClass("BodyColors")
		local Shirt = LocalPlayer.Character:FindFirstChildOfClass("Shirt")

		if BodyColors then
			BodyColors:Clone().Parent = clonedViewmodel
		end

		if Shirt then
			Shirt:Clone().Parent = clonedViewmodel
		end
	end

	task.spawn(function()
		if not ClientPlayerData.serverProfile then
			repeat
				task.wait()
			until ClientPlayerData.serverProfile
		end

		if not clonedViewmodel then
			return
		end

		Gloves:ApplyToViewmodel(clonedViewmodel, ClientPlayerData.serverProfile:getState().currentGloves)
		Watch:ApplyToViewmodel(clonedViewmodel, ClientPlayerData.serverProfile:getState().currentWatch)
	end)

	return clonedViewmodel :: WeaponTypes.Viewmodel
end
