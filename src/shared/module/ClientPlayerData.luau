local ReplicatedStorage = game:GetService("ReplicatedStorage")

local clientState = require(ReplicatedStorage.Shared.reflex.clientState)
local serverProfile = require(ReplicatedStorage.Shared.reflex.serverProfile)
local Bridgenet2 = require(ReplicatedStorage.package.Bridgenet2)
local Promise = require(ReplicatedStorage.package.Promise)
local Signal = require(ReplicatedStorage.package.Signal)

export type LocalProperties = {
	serverProfile: serverProfile.Producer?,
	clientProducer: clientState.Producer,
	isPlayerDataLoaded: boolean,
	playerDataLoadedSignal: Signal.Signal<()>,
}

local ClientPlayerData = {} :: LocalProperties

local getPlayerDataEvent = Bridgenet2.ClientBridge("GetPlayerData")
local replicateStoreEvent = Bridgenet2.ClientBridge("ReplicateStore")

local nextActionIsReplicated = false
local function replicateMiddleware()
	return function(dispatch, name)
		return function(...)
			if nextActionIsReplicated then
				nextActionIsReplicated = false
				return dispatch(...)
			end

			replicateStoreEvent:Fire({
				name = name,
				arguments = { ... },
			})

			return dispatch(...)
		end
	end
end

local loadData = Promise.retryWithDelay(function()
	return Promise.new(function(resolve, reject)
		local playerData = getPlayerDataEvent:InvokeServerAsync()

		if playerData then
			resolve(playerData)
		else
			reject("No data")
		end
	end)
end, math.huge, 0.25)

local function loadProfile()
	-- success jest wywalony bo promise i tak próbuje aż da radę się wykonać
	local _, serverPlayerData = loadData:await()
	local serverProfileProducer = serverProfile.CreateProducer(serverPlayerData)
	serverProfileProducer:applyMiddleware(replicateMiddleware)

	ClientPlayerData.serverProfile = serverProfileProducer
	ClientPlayerData.isPlayerDataLoaded = true
	ClientPlayerData.playerDataLoadedSignal:Fire()
end

task.spawn(loadProfile)

replicateStoreEvent:Connect(function(data)
	nextActionIsReplicated = true

	if not ClientPlayerData.isPlayerDataLoaded then
		warn("queued store action before player data loaded")
		ClientPlayerData.playerDataLoadedSignal:Wait()
	end

	ClientPlayerData.serverProfile[data.name](unpack(data.arguments))
end)

ClientPlayerData.clientProducer = clientState.CreateProducer(clientState.DEFAULT_STATE)
ClientPlayerData.isPlayerDataLoaded = false
ClientPlayerData.playerDataLoadedSignal = Signal.new()

return ClientPlayerData
