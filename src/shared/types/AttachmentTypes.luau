local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponConfigTypes = require(ReplicatedStorage.Shared.types.WeaponConfigTypes)

export type AttachmentClass<Object> = {
	__index: AttachmentClass<Object>,
	modelName: string,
	new: (attachment: Model, config: WeaponConfigTypes.Config) -> (),
	Enable: (self: Object) -> (),
	Disable: (self: Object) -> (),
	Destroy: (self: Object) -> (),
}

return table.freeze({})
