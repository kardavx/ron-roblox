local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.package.React)

type Props = {
	Padding: number?,
	FillDirection: Enum.FillDirection?,
	HorizontalAlignment: Enum.HorizontalAlignment?,
	VerticalAlignment: Enum.VerticalAlignment?,
	SortOrder: Enum.SortOrder?,
}

local function ListLayout(props: Props)
	return React.createElement("UIListLayout", {
		Padding = UDim.new(0, props.Padding or 8),
		FillDirection = props.FillDirection,
		SortOrder = props.SortOrder,
		HorizontalAlignment = props.HorizontalAlignment,
		VerticalAlignment = props.VerticalAlignment,
	})
end

return ListLayout
