export type UnknownClass = {
	__index: UnknownClass,
	new: () -> UnknownObject,
} & {
	Update: (self: UnknownObject, deltaTime: number) -> (),
	UpdateCharacter: (self: UnknownObject, character: Model?) -> (),
}

export type UnknownObject = typeof(setmetatable({} :: { [string]: unknown }, {} :: UnknownClass))

export type ClientMethods<self> = {
	Update: (self: self, deltaTime: number) -> (),
	PostUpdate: (self: self, deltaTime: number) -> (),
	UpdatePhysics: (self: self, deltaTime: number) -> (),
	UpdateCharacter: (self: self, character: Model?) -> (),
}

export type ServerMethods<self> = {
	Update: (self: self, deltaTime: number) -> (),
}

return table.freeze({})
