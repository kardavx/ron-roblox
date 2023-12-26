local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.package.React)

type Props = {
	Padding: number?,
	Direction: Enum.FillDirection?,
	XAlignment: Enum.HorizontalAlignment?,
	YAlignment: Enum.VerticalAlignment?,
	OrderedBy: Enum.SortOrder?,
}

local function ListLayout(props: Props)
	return React.createElement("UIListLayout", {
		Padding = UDim.new(0, props.Padding or 8),
		FillDirection = props.Direction,
		SortOrder = props.OrderedBy,
		HorizontalAlignment = props.XAlignment,
		VerticalAlignment = props.YAlignment,
	})
end

return ListLayout
