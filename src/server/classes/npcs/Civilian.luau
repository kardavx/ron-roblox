local ServerScriptService = game:GetService("ServerScriptService")

local NPC = require(ServerScriptService.classes.npcs.NPC)
local Civilian = {}
Civilian.__index = Civilian

function Civilian.new(intimidation: number | nil, aggressiveness: number | nil)
	local self = setmetatable({}, Civilian)
	self.npc = NPC.new("Civilian", intimidation, aggressiveness)

	return self
end

function Civilian:GetCharacter(...)
	return self.npc:GetCharacter(...)
end

function Civilian:Spawn(...)
	return self.npc:Spawn(...)
end

function Civilian:MoveTo(...)
	return self.npc:MoveTo(...)
end

function Civilian:SetState(...)
	return self.npc:SetState(...)
end

function Civilian:HandsUp(...)
	return self.npc:HandsUp(...)
end

function Civilian:Surrender(...)
	return self.npc:Surrender(...)
end

function Civilian:OnKnees(...)
	return self.npc:OnKnees(...)
end

function Civilian:StopMoving(...)
	return self.npc:StopMoving(...)
end

function Civilian:ScreamOn(...)
	return self.npc:ScreamOn(...)
end

function Civilian:GetPivot(...)
	return self.npc:GetPivot(...)
end

function Civilian:Destroy() end

return Civilian
