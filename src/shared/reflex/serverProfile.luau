--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Reflex = require(ReplicatedStorage.package.Reflex)

export type Producer = Reflex.Producer<State, Actions>

export type State = {
	weaponHiders: { string },
	leanFactor: number,
	mouseLockers: { string },
	currentGloves: string?,
	currentWatch: string?,
}

type Actions = {
	setLeanFactor: (newLeanFactor: number) -> (),
	addWeaponHider: (hiderId: string) -> (),
	removeWeaponHider: (hiderId: string) -> (),

	addMouseLocker: (lockerId: string) -> (),
	removeMouseLocker: (lockerId: string) -> (),

	setCurrentGloves: (gloveName: string?) -> (),
	setCurrentWatch: (watchName: string?) -> (),
}

local SAVED_STATE = {
	"currentGloves",
	"currentWatch",
}

local DEFAULT_STATE: State = {
	weaponHiders = {},
	mouseLockers = {},
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

		addWeaponHider = function(oldState: State, hiderId: string): State
			if table.find(oldState.weaponHiders, hiderId) then
				return oldState
			end

			local state = table.clone(oldState)
			state.weaponHiders = table.clone(state.weaponHiders)
			table.insert(state.weaponHiders, hiderId)

			return state
		end,
		removeWeaponHider = function(oldState: State, hiderId: string): State
			local hiderPosition = table.find(oldState.weaponHiders, hiderId)
			if not hiderPosition then
				return oldState
			end

			local state = table.clone(oldState)
			state.weaponHiders = table.clone(state.weaponHiders)
			table.remove(state.weaponHiders, hiderPosition)

			return state
		end,

		addMouseLocker = function(oldState: State, lockerId: string): State
			if table.find(oldState.mouseLockers, lockerId) then
				return oldState
			end

			local state = table.clone(oldState)
			state.mouseLockers = table.clone(state.mouseLockers)
			table.insert(state.mouseLockers, lockerId)

			return state
		end,

		removeMouseLocker = function(oldState: State, lockerId: string): State
			local hiderPosition = table.find(oldState.mouseLockers, lockerId)
			if not hiderPosition then
				return oldState
			end

			local state = table.clone(oldState)
			state.mouseLockers = table.clone(state.mouseLockers)
			table.remove(state.mouseLockers, hiderPosition)

			return state
		end,

		setCurrentGloves = function(oldState: State, glovesName: string): State
			local state = table.clone(oldState)
			state.currentGloves = glovesName

			return state
		end,
		setCurrentWatch = function(oldState: State, watchName: string): State
			local state = table.clone(oldState)
			state.currentWatch = watchName

			return state
		end,
	}) :: Producer

	return producer
end

return {
	CreateProducer = CreateProducer,
	DEFAULT_STATE = DEFAULT_STATE,
	SAVED_STATE = SAVED_STATE,
}
