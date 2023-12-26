--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Reflex = require(ReplicatedStorage.package.Reflex)

export type Producer = Reflex.Producer<State, Actions>

export type State = {
	leanFactor: number,
}

type Actions = {
	setLeanFactor: (newLeanFactor: number) -> (),
}

local DEFAULT_STATE: State = {
	leanFactor = 0,
}

function CreateProducer(initialState: State): Producer
	local producer = Reflex.createProducer(initialState, {
		setLeanFactor = function(oldState: State, newLeanFactor: number): State
			if newLeanFactor < -1 or newLeanFactor > 1 then
				warn(`Incorrect lean factor specified!`)
				return oldState
			end

			local state = table.clone(oldState)
			state.leanFactor = newLeanFactor

			return state
		end,
	}) :: Producer

	return producer
end

return {
	CreateProducer = CreateProducer,
	DEFAULT_STATE = DEFAULT_STATE,
}