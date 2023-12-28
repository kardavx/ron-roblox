local ReplicatedStorage = game:GetService("ReplicatedStorage")

local clientState = require(ReplicatedStorage.Shared.reflex.clientState)
local serverProfile = require(ReplicatedStorage.Shared.reflex.serverProfile)
local useSpring = require(ReplicatedStorage.Shared.ui.hook.useSpring)
local React = require(ReplicatedStorage.package.React)

type Props = {
	clientState: clientState.Producer,
	serverProfile: serverProfile.Producer?,
}

local function Router(props: Props)
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
			-- React.createElement(DebugUI, { common = commonProps }),
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
