local ReplicatedStorage = game:GetService("ReplicatedStorage")

local serverProfile = require(ReplicatedStorage.Shared.reflex.serverProfile)
local UITypes = require(ReplicatedStorage.Shared.types.UITypes)
local FullscreenFrame = require(ReplicatedStorage.Shared.ui.components.base.FullscreenFrame)
local DialogDisplay = require(ReplicatedStorage.Shared.ui.components.complex.Dialogs.DialogDisplay)
local Locker = require(ReplicatedStorage.Shared.ui.components.complex.Locker.Locker)
local MagsDisplay = require(ReplicatedStorage.Shared.ui.components.complex.Mags.MagsDisplay)
local Status = require(ReplicatedStorage.Shared.ui.components.complex.Status)
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

	if not props.serverProfile then
		return React.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, {
			React.createElement(FullscreenFrame, {
				BackgroundColor3 = Color3.new(),
				BackgroundTransparency = transparency:map(function(factor: number)
					return factor
				end),
			}),
		})
	end

	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		React.createElement(DialogDisplay, { common = commonProps }),
		React.createElement(MagsDisplay, { common = commonProps }),
		React.createElement(Status, {}),
		-- React.createElement(Locker, { common = commonProps }),
	})
end

return Router
