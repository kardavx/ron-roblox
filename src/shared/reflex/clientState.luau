--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Reflex = require(ReplicatedStorage.package.Reflex)

export type Producer = Reflex.Producer<State, Actions>

export type State = {
	weaponHiders: { string },
	DEBUG_COUNT: number,
}

type Actions = {
	increment: () -> (),
	addWeaponHider: (hiderId: string) -> (),
	removeWeaponHider: (hiderId: string) -> (),
}

local DEFAULT_STATE: State = {
	weaponHiders = {},
	DEBUG_COUNT = 0,
}

function CreateProducer(initialState: State): Producer
	local producer = Reflex.createProducer(initialState, {
		increment = function(oldState: State): State
			local state = table.clone(oldState)
			state.DEBUG_COUNT += 1
			return state
		end,

		addWeaponHider = function(oldState: State, hiderId: string): State
			if table.find(oldState.weaponHiders, hiderId) then
				return oldState
			end

			local state = table.clone(oldState)
			state.weaponHiders = table.clone(state.weaponHiders)
			table.insert(state, hiderId)

			return state
		end,

		removeWeaponHider = function(oldState: State, hiderId: string): State
			local hidersIndex = table.find(oldState.weaponHiders, hiderId)
			if not hidersIndex then
				return oldState
			end

			local state = table.clone(oldState)
			state.weaponHiders = table.clone(state.weaponHiders)
			table.remove(state, hidersIndex)

			return state
		end,
	}) :: Producer

	return producer
end

return {
	CreateProducer = CreateProducer,
	DEFAULT_STATE = DEFAULT_STATE,
}
