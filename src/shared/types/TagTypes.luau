export type OnInstanceAdded = (instance: Instance) -> { any }

export type TagDefinition = {
	tagName: string,
	onInstanceAdded: OnInstanceAdded,
}

return table.freeze({})
