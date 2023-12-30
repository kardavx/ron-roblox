local ReplicatedStorage = game:GetService("ReplicatedStorage")

local serverProfile = require(ReplicatedStorage.Shared.reflex.serverProfile)
local UITypes = require(ReplicatedStorage.Shared.types.UITypes)
local DialogDisplay = require(ReplicatedStorage.Shared.ui.components.complex.Dialogs.DialogDisplay)
local useSpring = require(ReplicatedStorage.Shared.ui.hook.useSpring)
local React = require(ReplicatedStorage.package.React)

local function Router(props: UITypes.CommonProps)
	local transparency, setTargetTransparency = useSpring({ initialValue = 0 })

	if props.serverProfile then
		print("setting target to 1")
		setTargetTransparency(1)
	else
		setTargetTransparency(0)
		print("setting target to 0")
	end

	local commonProps = {
		clientState = props.clientState,
		serverProfile = props.serverProfile :: serverProfile.Producer,
	}

	local routed
	if props.serverProfile then
		routed = {
			React.createElement(DialogDisplay, { common = commonProps }),
		}
	end

	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		React.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(),
			BackgroundTransparency = transparency:map(function(transparency: number)
				return transparency
			end),
		}),

		routed,
	})
end

return Router
