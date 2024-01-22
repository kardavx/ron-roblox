local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UITypes = require(ReplicatedStorage.Shared.types.UITypes)
local ListLayout = require(ReplicatedStorage.Shared.ui.components.base.ListLayout)
local SingleMag = require(ReplicatedStorage.Shared.ui.components.complex.Mags.SingleMag)
local useProducerAsState = require(ReplicatedStorage.Shared.ui.hook.useProducerAsState)
local ReactFor = require(ReplicatedStorage.Shared.ui.util.ReactFor)
local React = require(ReplicatedStorage.package.React)

type Props = {
	common: UITypes.CommonProps,
}

local function MagsDisplay(props: Props)
	local mags = {
		0.3,
		1,
		1,
		1,
	}

	local hudTransparency = useProducerAsState(props.common.clientState, function(state)
		return state.globalHUDTransparency
	end)

	return React.createElement("CanvasGroup", {
		Size = UDim2.fromScale(0.5, 0.05),
		GroupTransparency = hudTransparency,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1),
		BackgroundTransparency = 1,
	}, {
		React.createElement(ListLayout, {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),

		ReactFor(mags, function(fillFactor, index)
			return React.createElement(SingleMag, {
				fillFactor = fillFactor,
				magType = "Primary",
				current = index == 1,
			})
		end),
	})
end

return MagsDisplay
