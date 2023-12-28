local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = require(ReplicatedStorage.Shared.LocalPlayer)
local ListLayout = require(ReplicatedStorage.Shared.ui.components.base.ListLayout)
local useFor = require(ReplicatedStorage.Shared.ui.hook.useFor)
local React = require(ReplicatedStorage.package.React)
local ReactRoblox = require(ReplicatedStorage.package.ReactRoblox)

local Debug = {}
Debug.__index = Debug

type UIProps = {
	message: { string },
	position: UDim2,
}

local function debugUI(UIProps: UIProps)
	return React.createElement("Frame", {
		Position = UIProps.position,
		BackgroundTransparency = 1,
	}, {
		React.createElement(ListLayout, {
			Padding = 0,
			OrderedBy = Enum.SortOrder.LayoutOrder,
		}),

		useFor(UIProps.message, function(message: string, key: number)
			return React.createElement("TextLabel", {
				Text = message,
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundColor3 = Color3.new(),
				BackgroundTransparency = message == "" and 1 or 0.8,
				RichText = true,
				Name = key,
				LayoutOrder = key,
				TextSize = 12,
				TextColor3 = Color3.new(1.000000, 1.000000, 1.000000),
				Size = UDim2.fromOffset(0, 0),
			})
		end),
	})
end

function Debug.new(Position: UDim2?, Adornee: any?)
	local self = setmetatable({}, Debug)

	self.screenGui = Instance.new("ScreenGui")
	self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.screenGui.Name = "Debug"
	self.screenGui.Parent = LocalPlayer.PlayerGui

	self.root = ReactRoblox.createRoot(self.screenGui)
	self.Adornee = if Adornee then self:AssignAdornee(Adornee) else nil
	self.Position = Position
	self.Message = {}

	return self
end

function Debug:_GetFirstLine(message: string)
	local splitString = string.split(message, "\n")
	if #splitString == 0 then
		return message
	end

	return splitString[1]
end

function Debug:LogMessage(message: string)
	if self.Destroyed then
		return
	end

	self.Message = { message }
end

function Debug:LogMultilineMessage(messageTable: { string })
	if self.Destroyed then
		return
	end

	local actualMessageTable = {}

	for _, message in messageTable do
		table.insert(actualMessageTable, message)
	end

	self.Message = actualMessageTable
end

function Debug:SetPosition(Position: UDim2)
	self.Position = Position
end

function Debug:AssignAdornee(Adornee: BasePart | CFrame | Vector3 | Model | nil)
	if self.Destroyed then
		return
	end

	if not Adornee then
		self.Adornee = nil
		return
	end

	if typeof(Adornee) == "Instance" and Adornee:IsA("Model") then
		if not Adornee.PrimaryPart then
			error(`Only models with primaryParts are supported as adornees!`)
		end

		self.Adornee = Adornee.PrimaryPart
	else
		self.Adornee = Adornee
	end
end

function Debug:Update()
	if self.Destroyed then
		return
	end

	self.root:unmount()

	if not self.Adornee then
		if self.Position then
			self.root:render(React.createElement(debugUI, {
				message = self.Message,
				position = self.Position,
			}))
		else
			self.root:render(React.createElement(debugUI, {
				message = self.Message,
				position = UDim2.fromOffset(math.huge, math.huge),
			}))
		end

		return
	end

	--// because type annotations
	local Adornee = self.Adornee
	local Position, OnScreen

	if typeof(Adornee) == "Instance" then
		if not Adornee:IsA("BasePart") then
			return
		end

		Position, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(Adornee.Position)
	elseif typeof(Adornee) == "CFrame" then
		Position, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(Adornee.Position)
	elseif typeof(Adornee) == "Vector3" then
		Position, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(Adornee)
	end

	if OnScreen then
		Position = UDim2.new(0, Position.X, 0, Position.Y)
	else
		Position = UDim2.new(0, math.huge, 0, math.huge)
	end

	self.root:render(React.createElement(debugUI, {
		message = self.Message,
		position = Position,
	}))
end

function Debug:Destroy()
	self.Destroyed = true
	self.root:unmount()
	self.screenGui:Destroy()
end

return Debug
