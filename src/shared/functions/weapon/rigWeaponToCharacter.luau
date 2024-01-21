local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponTypes = require(ReplicatedStorage.Shared.types.WeaponTypes)
local createInstance = require(ReplicatedStorage.Shared.util.createInstance)

local function rigWeaponToCharacter(character: Model, weaponClone: WeaponTypes.Weapon)
	weaponClone.Parent = character
	weaponClone.Name = "weapon"

	local rightArm = character:FindFirstChild("Right Arm") :: BasePart

	createInstance("Motor6D", {
		Part0 = rightArm,
		Part1 = weaponClone.Handle,
		Parent = rightArm,
		Name = "Handle",
	})

	for _, descendant: Instance in weaponClone:GetDescendants() do
		if not descendant:IsA("BasePart") then
			continue
		end

		descendant.CollisionGroup = "viewmodel"
		descendant.CanCollide = false
		descendant.CanQuery = false
		descendant.CanTouch = false
	end
end

return rigWeaponToCharacter
