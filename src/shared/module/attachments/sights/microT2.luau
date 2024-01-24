local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AttachmentTypes = require(ReplicatedStorage.Shared.types.AttachmentTypes)
local WeaponConfigTypes = require(ReplicatedStorage.Shared.types.WeaponConfigTypes)

export type Object = typeof(setmetatable({} :: {}, {} :: AttachmentTypes.AttachmentClass<Object>))

local microT2: AttachmentTypes.AttachmentClass<Object> = {} :: AttachmentTypes.AttachmentClass<Object>
microT2.__index = microT2

function microT2.new(attachment: Model, config: WeaponConfigTypes.Config) end

return microT2
