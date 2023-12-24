export type NodeClass = {
	__index: NodeClass,
	new: () -> NodeObject,
	Initialize: (self: NodeObject, ...any) -> (),
	PreUpdate: (self: NodeObject, deltaTime: number, ...any) -> (),
	Update: (self: NodeObject, deltaTime: number, currentCFrame: CFrame, ...any) -> CFrame,
	PostUpdate: (self: NodeObject, deltaTime: number, ...any) -> (),
}

export type NodeObject = typeof(setmetatable({} :: { [string]: any }, {} :: NodeClass))

return table.freeze({})
