local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Maid = require(ReplicatedStorage.package.Maid)
local playerClass = require(ServerScriptService.classes.player)
-- require(ServerScriptService.NPCTest)

---// inicjalizuje serverDate, nie pytaj czemu w taki sposob - shibe to wymyslil XD
require(ServerScriptService.module.ServerPlayerData)

local playerObjects: { [string]: playerClass.Object } = {}
local playerJanitors: { [string]: Maid.Maid } = {}
local characterJanitors: { [string]: Maid.Maid } = {}

local function playerAdded(player: Player)
	local janitor = Maid.new()

	playerObjects[player.Name] = playerClass.new(player)

	janitor:GiveTask(function()
		local playerObject = playerObjects[player.Name] :: playerClass.Object

		playerObject:Destroy()
		playerObjects[player.Name] = nil
	end)

	janitor:GiveTask(player.CharacterAdded:Connect(function(character: Model)
		local playerObject = playerObjects[player.Name] :: playerClass.Object
		local characterJanitor = Maid.new()
		local humanoid = character:WaitForChild("Humanoid") :: Humanoid

		characterJanitor:GiveTask(humanoid.Died:Connect(function()
			playerObject:OnCharacterDied()
		end))

		playerObject:UpdateCharacter(character)
	end))

	janitor:GiveTask(player.CharacterRemoving:Connect(function()
		local playerObject = playerObjects[player.Name] :: playerClass.Object
		playerObject:UpdateCharacter(nil)

		local characterJanitor = characterJanitors[player.Name]
		if characterJanitor then
			characterJanitor:Destroy()
			characterJanitors[player.Name] = nil
		end
	end))

	playerJanitors[player.Name] = janitor
end

Players.PlayerAdded:Connect(function(player: Player)
	playerAdded(player)
end)

-- for _, player in Players:GetPlayers() do
-- 	playerAdded(player)
-- end

Players.PlayerRemoving:Connect(function(player: Player)
	local playerJanitor = playerJanitors[player.Name] :: Maid.Maid

	if playerJanitor then
		playerJanitor:Destroy()
		playerJanitors[player.Name] = nil
	end
end)

RunService.Heartbeat:Connect(function(deltaTime: number)
	for _, playerObject in playerObjects do
		playerObject:Update(deltaTime)
	end
end)
