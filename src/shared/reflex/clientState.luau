--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Reflex = require(ReplicatedStorage.package.Reflex)

export type Producer = Reflex.Producer<State, Actions>

export type State = {
	DEBUG_COUNT: number,
}

type Actions = {
	increment: () -> (),
}

local DEFAULT_STATE: State = {
	DEBUG_COUNT = 0,
}

function CreateProducer(initialState: State): Producer
	local producer = Reflex.createProducer(initialState, {
		increment = function(oldState: State): State
			local state = table.clone(oldState)
			state.DEBUG_COUNT += 1
			return state
		end,
	}) :: Producer

	return producer
end

return {
	CreateProducer = CreateProducer,
	DEFAULT_STATE = DEFAULT_STATE,
}
