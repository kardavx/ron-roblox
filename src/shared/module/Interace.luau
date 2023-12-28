local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = require(ReplicatedStorage.Shared.LocalPlayer)
local ClientPlayerData = require(ReplicatedStorage.Shared.module.ClientPlayerData)
local router = require(ReplicatedStorage.Shared.ui.router)
local Maid = require(ReplicatedStorage.package.Maid)
local React = require(ReplicatedStorage.package.React)
local ReactRoblox = require(ReplicatedStorage.package.ReactRoblox)

local Interface = {}
local janitor = Maid.new()

local function cleanupUI()
	janitor:DoCleaning()
end

local function createUI()
	cleanupUI()

	local screenGui = Instance.new("ScreenGui")
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local root = ReactRoblox.createRoot(screenGui)

	screenGui.Name = "Client"
	screenGui.Parent = LocalPlayer.PlayerGui

	root:render(React.createElement(router, {
		clientState = ClientPlayerData.clientProducer,
		serverProfile = ClientPlayerData.serverProfile,
	}))

	if ClientPlayerData.isPlayerDataLoaded then
		return
	end

	ClientPlayerData.playerDataLoadedSignal:Once(function()
		root:render(React.createElement(router, {
			clientState = ClientPlayerData.clientProducer,
			serverProfile = ClientPlayerData.serverProfile,
		}))
	end)

	janitor:GiveTask(function()
		root:unmount()
	end)
	janitor:GiveTask(screenGui)
end

function Interface:UpdateCharacter(character: Model?)
	if character then
		createUI()
	else
		cleanupUI()
	end
end

return Interface
