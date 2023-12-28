--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local serverProfile = require(ReplicatedStorage.Shared.reflex.serverProfile)
local serverDatastoreKeys = require(ServerScriptService.configurations.serverDatastoreKeys)
local Bridgenet2 = require(ReplicatedStorage.package.Bridgenet2)
local ProfileService = require(ReplicatedStorage.package.ProfileService)
local Promise = require(ReplicatedStorage.package.Promise)
local Reflex = require(ReplicatedStorage.package.Reflex)
local Signal = require(ReplicatedStorage.package.Signal)

type Profile = {
	-- Data: serverProfile.State, NIE UŻYWAĆ
	Release: (self: Profile) -> (),
}

export type ServerPlayerProfile = {
	player: Player,
	profileStore: Profile,
	producer: serverProfile.Producer,
	nextActionIsReplicated: boolean,
}

type LocalProperties = {
	GetPlayerProfile: (player: Player) -> ServerPlayerProfile?,
	WaitForPlayerProfile: (player: Player) -> Promise.TypedPromise<ServerPlayerProfile>,
}

local ServerPlayerData: LocalProperties = {} :: LocalProperties

local ProfileStore = ProfileService.GetProfileStore(serverDatastoreKeys.storeKey, serverProfile.DEFAULT_STATE)

local playerProfiles: { [Player]: ServerPlayerProfile? } = {}
local getPlayerDataEvent = Bridgenet2.ServerBridge("GetPlayerData")
local replicateStoreEvent = Bridgenet2.ServerBridge("ReplicateStore")
local playerDataLoadedEvent: Signal.Signal<Player, ServerPlayerProfile> = Signal.new()

local function playerAdded(player)
	local profileStore = ProfileStore:LoadProfileAsync(serverDatastoreKeys.getKey(player.UserId))

	if not profileStore then
		player:Kick()
		return
	end

	profileStore:AddUserId(player.UserId) -- GDPR compliance
	profileStore:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
	profileStore:ListenToRelease(function()
		playerProfiles[player] = nil
		-- The profile could've been loaded on another Roblox server:
		player:Kick()
	end)

	if not player:IsDescendantOf(Players) then
		-- Player left before the profile loaded:
		profileStore:Release()
	end

	local profile: ServerPlayerProfile = {
		player = player,
		profileStore = profileStore,
		producer = serverProfile.CreateProducer(profileStore.Data),
		nextActionIsReplicated = false,
	}

	local replicateMiddleware: Reflex.Middleware = function()
		return function(dispatch, name)
			return function(...)
				if profile.nextActionIsReplicated then
					profile.nextActionIsReplicated = false
					return dispatch(...)
				end

				replicateStoreEvent:Fire(player, {
					name = name,
					arguments = { ... },
				})

				return dispatch(...)
			end
		end
	end

	profile.producer:applyMiddleware(replicateMiddleware)

	playerProfiles[player] = profile
	playerDataLoadedEvent:Fire(player, profile)
end

local function playerRemoving(player)
	local profile = playerProfiles[player]
	if not profile then
		return
	end

	-- NIE DOTYKAĆ! potrzebne do zapisu danych
	(profile.profileStore :: any).Data = profile.producer:getState()

	profile.profileStore:Release()
	playerProfiles[player] = nil
end

-- oddzielone bo w przyszłości może będzie potrzeba przez userid to robić
function ServerPlayerData.GetPlayerProfile(player: Player)
	return playerProfiles[player]
end

function ServerPlayerData.WaitForPlayerProfile(player: Player)
	return Promise.new(function(resolve, reject)
		local profile = ServerPlayerData.GetPlayerProfile(player)
		if profile then
			resolve(profile)
			return
		end
		playerDataLoadedEvent:Once(function(newPlayer, data)
			if newPlayer ~= player then
				return
			end
			resolve(data)
		end)
	end)
end

getPlayerDataEvent.OnServerInvoke = function(player)
	local profile = ServerPlayerData.GetPlayerProfile(player)
	if not profile then
		return
	end

	return (profile.profileStore :: any).Data
end

replicateStoreEvent:Connect(function(player, data: any)
	if type(data) ~= "table" then
		return
	end

	local isSecureAction = data.name:find("^secure")
	if isSecureAction then
		warn("Player tried to replicate secure reflex action", data.name)
		return
	end

	local profile = ServerPlayerData.GetPlayerProfile(player)
	if not profile then
		return
	end

	profile.nextActionIsReplicated = true;
	(profile.producer :: any)[data.name](unpack(data.arguments))
end)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(playerAdded, player)
end

Players.PlayerAdded:Connect(playerAdded)
Players.PlayerRemoving:Connect(playerRemoving)

return ServerPlayerData
