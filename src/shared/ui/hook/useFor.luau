local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.package.React)
local function useFor<Key, Value>(
	iterator: { [Key]: Value },
	callback: (element: Value, key: Key) -> React.ReactElement<unknown, unknown>
): { React.ReactElement<unknown, unknown> }
	local elements: { React.ReactElement<unknown, unknown> } = {}

	for key, element in iterator do
		table.insert(elements, callback(element, key))
	end

	return elements
end

return useFor
