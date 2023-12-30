local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DialogTypes = require(ReplicatedStorage.Shared.types.DialogTypes)
local useSpring = require(ReplicatedStorage.Shared.ui.hook.useSpring)
local React = require(ReplicatedStorage.package.React)

type Props = {
	Occlusion: DialogTypes.Occlusion,
	Text: string,
	Name: string?,
}

local OcclusionToColor: { [DialogTypes.Occlusion]: Color3 } = {
	Enemy = Color3.new(0.894118, 0.250980, 0.250980),
	Unknown = Color3.new(0.913725, 0.905882, 0.380392),
	Friendly = Color3.new(0.227451, 0.568627, 0.960784),
}

local function getName(props: Props)
	if props.Name then
		return props.Name
	end

	if props.Occlusion == "Enemy" then
		return "Suspect"
	end

	return "Unknown"
end

local function Dialog(props: Props)
	local fade, setFade = useSpring({ initialValue = 1, speed = 100 })

	setFade(0)

	return React.createElement("TextLabel", {
		Text = `{getName(props)}: <font color="rgb(255,255,255)">{props.Text}</font>`,
		RichText = true,
		Font = Enum.Font.Gotham,
		Size = UDim2.fromScale(1, 0.06),
		TextScaled = true,
		TextStrokeTransparency = fade:map(function(value: number)
			return value
		end),
		TextTransparency = fade:map(function(value: number)
			return value
		end),
		TextColor3 = OcclusionToColor[props.Occlusion],
		BackgroundTransparency = 1,
	}, {
		React.createElement("UITextSizeConstraint", {
			MaxTextSize = 25,
		}),
	})
end

return Dialog
