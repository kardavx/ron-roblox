local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.package.React)
type Props = {
	Size: number,
}

local function Padding(props: Props)
	return React.createElement("UIPadding", {
		PaddingBottom = UDim.new(0, props.Size),
		PaddingLeft = UDim.new(0, props.Size),
		PaddingRight = UDim.new(0, props.Size),
		PaddingTop = UDim.new(0, props.Size),
	})
end

return Padding
