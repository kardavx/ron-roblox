--!native

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local clientState = require(ReplicatedStorage.Shared.reflex.clientState)
local serverProfile = require(ReplicatedStorage.Shared.reflex.serverProfile)
local router = require(ReplicatedStorage.Shared.ui.router)
local Maid = require(ReplicatedStorage.package.Maid)

-- temporary fix
local React = require(ReplicatedStorage.package.React)
local ReactRoblox = require(ReplicatedStorage.package.ReactRoblox)

local DEBUG_LOADING_TIME = 1

return function(target: Instance)
	local maid = Maid.new()
	local root = ReactRoblox.createRoot(target)
	local killed = false

	local success, failure = pcall(function()
		local clientStateStore = clientState.CreateProducer(clientState.DEFAULT_STATE)
		local serverStateStore = serverProfile.CreateProducer(serverProfile.DEFAULT_STATE)

		print("loading start")

		root:render(React.createElement(router, {
			clientState = clientStateStore,
		}))

		task.delay(DEBUG_LOADING_TIME, function()
			if killed then
				return
			end

			print("loading end")

			root:render(React.createElement(router, {
				clientState = clientStateStore,
				serverProfile = serverStateStore,
			}))
		end)

		maid:GiveTask(function()
			root:render(nil)
		end)
	end)

	if not success then
		warn("Error while running GameRouter")
		warn(failure)
	end

	return function()
		killed = true
		maid:DoCleaning()
	end
end
