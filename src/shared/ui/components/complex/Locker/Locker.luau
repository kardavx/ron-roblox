local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UITypes = require(ReplicatedStorage.Shared.types.UITypes)
local FullscreenFrame = require(ReplicatedStorage.Shared.ui.components.base.FullscreenFrame)
local ListLayout = require(ReplicatedStorage.Shared.ui.components.base.ListLayout)
local Padding = require(ReplicatedStorage.Shared.ui.components.base.Padding)
local React = require(ReplicatedStorage.package.React)

type Props = {
	common: UITypes.CommonProps,
}

local function Locker(props: Props)
	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		React.createElement(FullscreenFrame, {
			BackgroundColor3 = Color3.new(1, 1, 1),
		}, {
			React.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
					ColorSequenceKeypoint.new(0.1, Color3.new(0, 0, 0)),
					ColorSequenceKeypoint.new(1, Color3.new(0.113725, 0.003922, 0.003922)),
				}),
			}),
		}),

		React.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ZIndex = 2,
		}, {
			React.createElement(Padding, {
				Size = 50,
			}),

			React.createElement(ListLayout, {
				Padding = 450,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			React.createElement("Frame", {
				Size = UDim2.fromScale(0.3, 1),
				BackgroundColor3 = Color3.new(0.788235, 0.000000, 0.000000),
			}, {
				React.createElement(Padding, {
					Size = 20,
				}),

				React.createElement("UIGradient", {
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(0.2, 1),
						NumberSequenceKeypoint.new(1, 1),
					}),
					Rotation = 90,
				}),

				React.createElement(ListLayout, {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
				}),

				React.createElement("Frame", {
					Size = UDim2.fromScale(1, 0.05),
					BackgroundTransparency = 1,
				}, {
					React.createElement(ListLayout, {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
					}),

					React.createElement("TextLabel", {
						Size = UDim2.fromScale(0.9, 1),
						BackgroundTransparency = 1,
						Font = Enum.Font.GothamBold,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextScaled = true,
						TextColor3 = Color3.new(1, 1, 1),
						Text = "LAPD LOCKER",
					}),

					React.createElement("ImageLabel", {
						Image = "rbxassetid://4489173367",
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 1),
					}, {
						React.createElement("UIAspectRatioConstraint", {
							AspectRatio = 1 / 1,
						}),
					}),
				}),

				React.createElement("TextLabel", {
					Size = UDim2.fromScale(1, 0.03),
					BackgroundTransparency = 1,
					Font = Enum.Font.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextScaled = true,
					TextColor3 = Color3.new(1, 1, 1),
					Text = "Gear your officer out",
				}),

				React.createElement("Frame", {
					Size = UDim2.new(1, 0, 0, 2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.new(1, 1, 1),
				}),

				React.createElement("Frame", {
					Size = UDim2.fromScale(1, 0.08),
					BackgroundTransparency = 1,
				}, {
					React.createElement(Padding, {
						Size = 10,
					}),

					React.createElement(ListLayout, {
						Padding = 0,
						FillDirection = Enum.FillDirection.Horizontal,
					}),

					React.createElement("TextButton", {
						Size = UDim2.fromScale(0.5, 1),
						BackgroundColor3 = Color3.new(0.058824, 0.058824, 0.058824),
						TextColor3 = Color3.new(1, 1, 1),
						TextScaled = true,
						Font = Enum.Font.GothamMedium,
						BorderSizePixel = 0,
						Text = "Character",
					}, {
						React.createElement("UITextSizeConstraint", {
							MaxTextSize = 20,
						}),
					}),

					React.createElement("TextButton", {
						Size = UDim2.fromScale(0.5, 1),
						BackgroundColor3 = Color3.new(0.058824, 0.058824, 0.058824),
						TextColor3 = Color3.new(1, 1, 1),
						TextScaled = true,
						Font = Enum.Font.GothamMedium,
						BorderSizePixel = 0,
						Text = "Loadout",
					}, {
						React.createElement("UITextSizeConstraint", {
							MaxTextSize = 20,
						}),
					}),
				}),
			}),

			React.createElement("Frame", {
				Size = UDim2.fromScale(0.4, 1),
				BackgroundColor3 = Color3.new(0, 0),
				BackgroundTransparency = 1,
			}),
		}),
	})
end

return Locker
