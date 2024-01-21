local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Padding = require(ReplicatedStorage.Shared.ui.components.base.Padding)
local React = require(ReplicatedStorage.package.React)

type Props = {
	BackgroundColor3: Color3?,
	BackgroundTransparency: (number | React.Binding<number>)?,
	PaddingPx: number?,

	Visible: boolean?,

	children: unknown?,
}

local function FullscreenFrame(props: Props)
	local inset = GuiService:GetGuiInset()

	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1),
		Size = UDim2.new(1, 0, 1, inset.Y),
		Visible = props.Visible,
		BackgroundColor3 = props.BackgroundColor3,
		BackgroundTransparency = props.BackgroundTransparency,
	}, {
		React.createElement(Padding, {
			Size = props.PaddingPx or 8,
		}),

		props.children,
	})
end

return FullscreenFrame
