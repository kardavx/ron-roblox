local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Reflex = require(ReplicatedStorage.package.Reflex)
local React = require(ReplicatedStorage.package.React)

local function useProducerAsBinding<State, Dispatchers, Comparison>(
	producer: Reflex.Producer<State, Dispatchers>,
	getSlice: (state: State) -> Comparison
)
	local value, setValue = React.useBinding(getSlice(producer:getState()))

	React.useEffect(function()
		local disconnect = producer:subscribe(getSlice, function(newValue: Comparison)
			setValue(newValue)
		end)

		return disconnect
	end)

	return value
end

return useProducerAsBinding
