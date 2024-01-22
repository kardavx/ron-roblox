local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.package.React)

local function ReactConditional(
	condition: boolean | React.Binding<boolean>,
	elements: { any } | any
): React.ReactElement<any, any>
	if typeof(elements) ~= "table" then
		elements = { elements }
	end

	return React.createElement(
		"Frame",
		{ Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = condition },
		elements
	)
end

return ReactConditional
