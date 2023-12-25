local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Reflex = require(ReplicatedStorage.package.Reflex)
local React = require(ReplicatedStorage.package.React)

local function useProducerAsState<State, Dispatchers, Comparison>(producer, getSlice: (state: State) -> Comparison, dependencies: { any? }?)
	local value, setValue = React.useState(getSlice(producer:getState()))
	local lastValue, setLastValue = React.useState(getSlice(producer:getState()))

	React.useEffect(function()
		-- jeśli dependencies się zaktualizują, state musi się zaktualizować
		setValue(getSlice(producer:getState()))

		local disconnect = producer:subscribe(getSlice, function(newValue: Comparison, lastValue: Comparison)
			setValue(newValue)
			setLastValue(lastValue)
		end)

		return disconnect
	end, dependencies)

	return value, lastValue
end

return useProducerAsState
