local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PaddingBottom = require(ReplicatedStorage.Shared.ui.components.base.PaddingBottom)
local React = require(ReplicatedStorage.package.React)
type MagType = "Primary" | "Secondary"

type Props = {
	fillFactor: number,
	magType: MagType,
	current: boolean,
}

local magTypeToImage: { [MagType]: number } = {
	Primary = 16066661786,
	Secondary = 16066661786,
}

local function SingleMag(props: Props)
	local fillFactorGradient = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(math.max(1 - props.fillFactor, 0.01), 1),
		NumberSequenceKeypoint.new(math.min((1 - props.fillFactor) + 0.01, 0.99), 0),
		NumberSequenceKeypoint.new(1, 0),
	})

	local desiredTransparency

	if props.fillFactor == 0 then
		desiredTransparency = NumberSequence.new(1)
	elseif props.fillFactor == 1 then
		desiredTransparency = NumberSequence.new(0)
	else
		desiredTransparency = fillFactorGradient
	end

	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 1 / 1,
		}),

		React.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		}, {
			React.createElement(PaddingBottom, {
				Size = 15,
			}),

			React.createElement("ImageLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				ImageColor3 = Color3.new(0, 0, 0),
				ImageTransparency = 0.7,
				Image = `rbxassetid://{magTypeToImage[props.magType]}`,
			}),

			React.createElement("ImageLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = `rbxassetid://{magTypeToImage[props.magType]}`,
			}, {
				React.createElement("UIGradient", {
					Transparency = desiredTransparency,
					Rotation = 90,
				}),
			}),
		}),

		React.createElement("Frame", {
			Size = UDim2.new(0.7, 0, 0, 2),
			BackgroundColor3 = Color3.new(1.000000, 1.000000, 1.000000),
			BorderSizePixel = 0,
			Visible = props.current,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
		}, {
			React.createElement("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.5, 0),
					NumberSequenceKeypoint.new(1, 1),
				}),
			}),
		}),
	})
end

return SingleMag
