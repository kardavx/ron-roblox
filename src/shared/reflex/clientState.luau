--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local dialogData = require(ReplicatedStorage.Shared.data.dialogData)
local DialogTypes = require(ReplicatedStorage.Shared.types.DialogTypes)
local Reflex = require(ReplicatedStorage.package.Reflex)

export type Producer = Reflex.Producer<State, Actions>

export type State = {
	activeDialogs: { { dialogId: string, dialogEnd: number } },
	DEBUG_COUNT: number,
}

type Actions = {
	increment: () -> (),
	addDialog: (dialogId: string) -> (),
	removeDialog: (dialogPosition: number) -> (),
}

local DEFAULT_STATE: State = {
	activeDialogs = {},
	DEBUG_COUNT = 0,
}

local function getDialogTime(dialogText: string): number
	return 0.15 * string.len(dialogText)
end

function CreateProducer(initialState: State): Producer
	local producer = Reflex.createProducer(initialState, {
		increment = function(oldState: State): State
			local state = table.clone(oldState)
			state.DEBUG_COUNT += 1
			return state
		end,

		addDialog = function(oldState: State, dialogId: string): State
			local configFromId = dialogData[dialogId]

			local state = table.clone(oldState)
			state.activeDialogs = table.clone(state.activeDialogs)

			table.insert(
				state.activeDialogs,
				{ dialogId = dialogId, dialogEnd = tick() + getDialogTime(configFromId.Text) }
			)

			return state
		end,

		removeDialog = function(oldState: State, dialogPosition: number): State
			local state = table.clone(oldState)
			state.activeDialogs = table.clone(state.activeDialogs)
			table.remove(state.activeDialogs, dialogPosition)

			print(state)

			return state
		end,
	}) :: Producer

	return producer
end

return {
	CreateProducer = CreateProducer,
	DEFAULT_STATE = DEFAULT_STATE,
}
