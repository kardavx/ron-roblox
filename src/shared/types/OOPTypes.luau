export type UnknownClass = {
	__index: UnknownClass,
	new: () -> UnknownObject,
} & {
	Update: (self: UnknownObject, deltaTime: number) -> (),
	UpdateCharacter: (self: UnknownObject, character: Model?) -> (),
}

export type UnknownObject = typeof(setmetatable({} :: { [string]: unknown }, {} :: UnknownClass))

export type ClientClassMethods<Object> = {
	Update: (self: Object, deltaTime: number) -> (),
	PostUpdate: (self: Object, deltaTime: number) -> (),
	UpdatePhysics: (self: UnknownObject, deltaTime: number) -> (),
	UpdateCharacter: (self: Object, character: Model?) -> (),
}

return table.freeze({})
