export type InputTypes = "Hold" | "Click"

export type InputMap = {
	[string]: {
		keyCode: Enum.KeyCode | Enum.UserInputType,
		inputType: InputTypes,
	},
}

return table.freeze({})
