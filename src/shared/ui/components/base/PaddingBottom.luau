local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.package.React)
type Props = {
	Size: number,
}

local function PaddingBottom(props: Props)
	return React.createElement("UIPadding", {
		PaddingBottom = UDim.new(0, props.Size),
	})
end

return PaddingBottom
