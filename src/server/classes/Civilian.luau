local ServerScriptService = game:GetService("ServerScriptService")

local NPC = require(ServerScriptService.classes.NPC)
local Civilian = {}
Civilian.__index = Civilian

function Civilian.new(intimidation: number | nil, aggressiveness: number | nil)
	local self = setmetatable({}, Civilian)
	self.npc = NPC.new("Civilian", intimidation, aggressiveness)

	return self
end

function Civilian:Spawn(...)
	self.npc:Spawn(...)
end

function Civilian:Destroy() end

return Civilian
