local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CurrentCamera = require(ReplicatedStorage.Shared.CurrentCamera)
local LocalPlayer = require(ReplicatedStorage.Shared.LocalPlayer)
local ClientPlayerData = require(ReplicatedStorage.Shared.module.ClientPlayerData)
local Gloves = require(ReplicatedStorage.Shared.module.Gloves)
local Watch = require(ReplicatedStorage.Shared.module.Watch)
local WeaponTypes = require(ReplicatedStorage.Shared.types.WeaponTypes)
local createInstance = require(ReplicatedStorage.Shared.util.createInstance)

-- local viewmodelsStorage = ReplicatedStorage.Viewmodels :: Folder
local weaponsStorage = ReplicatedStorage.Weapons :: Folder
local viewmodel = ReplicatedStorage.Viewmodel

return function(weaponName: string): WeaponTypes.Viewmodel
	local viewmodelClone = viewmodel:Clone() :: WeaponTypes.Viewmodel
	local desiredWeapon = weaponsStorage:FindFirstChild(weaponName) :: WeaponTypes.Weapon
	if not desiredWeapon then
		error(`Couldn't find weapon of name {weaponName}`)
	end

	local clonedWeapon = desiredWeapon:Clone()
	clonedWeapon.Parent = viewmodelClone
	clonedWeapon.Name = "weapon"

	local magPart = clonedWeapon:FindFirstChild("Mag") or clonedWeapon:FindFirstChild("Magazine")

	createInstance("Motor6D", {
		Part0 = viewmodelClone.HumanoidRootPart,
		Part1 = clonedWeapon.Handle,
		Parent = viewmodelClone.HumanoidRootPart,
		Name = "Handle",
	})
	createInstance("Motor6D", {
		Part0 = magPart,
		Part1 = viewmodelClone["Left Arm"],
		Parent = magPart,
		Name = "Left Arm",
	})
	createInstance("Motor6D", {
		Part0 = clonedWeapon.Handle,
		Part1 = viewmodelClone["Right Arm"],
		Parent = clonedWeapon.Handle,
		Name = "Right Arm",
	})

	viewmodelClone.Parent = CurrentCamera

	for _, descendant: Instance in viewmodelClone:GetDescendants() do
		if not descendant:IsA("BasePart") then
			continue
		end

		descendant.CollisionGroup = "viewmodel"
		descendant.CanCollide = false
		descendant.CanQuery = false
		descendant.CanTouch = false
	end

	if LocalPlayer.Character then
		local BodyColors = LocalPlayer.Character:FindFirstChildOfClass("BodyColors")
		local Shirt = LocalPlayer.Character:FindFirstChildOfClass("Shirt")

		if BodyColors then
			BodyColors:Clone().Parent = viewmodelClone
		end

		if Shirt then
			Shirt:Clone().Parent = viewmodelClone
		end
	end

	task.spawn(function()
		if not ClientPlayerData.serverProfile then
			repeat
				task.wait()
			until ClientPlayerData.serverProfile
		end

		if not viewmodelClone then
			return
		end

		Gloves:ApplyToViewmodel(viewmodelClone, ClientPlayerData.serverProfile:getState().currentGloves)
		Watch:ApplyToViewmodel(viewmodelClone, ClientPlayerData.serverProfile:getState().currentWatch)
	end)

	return viewmodelClone :: WeaponTypes.Viewmodel
end
