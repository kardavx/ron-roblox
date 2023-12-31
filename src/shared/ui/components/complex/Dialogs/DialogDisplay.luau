local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local dialogData = require(ReplicatedStorage.Shared.data.dialogData)
local UITypes = require(ReplicatedStorage.Shared.types.UITypes)
local Padding = require(ReplicatedStorage.Shared.ui.components.base.Padding)
local Dialog = require(ReplicatedStorage.Shared.ui.components.complex.Dialogs.Dialog)
local useProducerAsState = require(ReplicatedStorage.Shared.ui.hook.useProducerAsState)
local ReactFor = require(ReplicatedStorage.Shared.ui.util.ReactFor)
local Maid = require(ReplicatedStorage.package.Maid)
local React = require(ReplicatedStorage.package.React)

type Props = {
	common: UITypes.CommonProps,
}

local function DialogDisplay(props: Props)
	local dialogIds = useProducerAsState(props.common.clientState, function(state)
		return state.activeDialogs
	end)

	React.useEffect(function()
		local janitor = Maid.new()

		janitor:GiveTask(RunService.Heartbeat:Connect(function()
			for dialogPosition, dialogInfo in dialogIds do
				if tick() >= dialogInfo.dialogEnd then
					props.common.clientState.removeDialog(dialogPosition)
				end
			end
		end))

		return function()
			janitor:Destroy()
			janitor = nil
		end
	end)

	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1),
		Size = UDim2.fromScale(0.5, 0.6),
	}, {
		React.createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
		}),

		React.createElement(Padding, {
			Size = 30,
		}),

		ReactFor(dialogIds, function(dialog: { dialogId: string, dialogEnd: number })
			local configFromId = dialogData[dialog.dialogId]

			return React.createElement(Dialog, {
				Occlusion = configFromId.Occlusion,
				Text = configFromId.Text,
				Name = configFromId.Name,
			})
		end),
	})
end

return DialogDisplay
