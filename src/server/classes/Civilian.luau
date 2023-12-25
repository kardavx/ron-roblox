local ServerScriptService = game:GetService("ServerScriptService")

local NPC = require(ServerScriptService.classes.NPC)
local Civilian = {}
Civilian.__index = Civilian

function Civilian.new(modelName: string, spawnCFrame: CFrame)
	local self = setmetatable({}, Civilian)
	self.npc = NPC.new("Civilian", modelName, spawnCFrame)

	return self
end

function Civilian:Destroy() end

return Civilian
