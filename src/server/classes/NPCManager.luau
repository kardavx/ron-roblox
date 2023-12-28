local ServerScriptService = game:GetService("ServerScriptService")

local NPCManager = { npcs = {} }
NPCManager.__index = NPCManager

function NPCManager.new()
	local self = setmetatable({}, NPCManager)

	return self
end

function NPCManager:GetNPCFromCharacter(character: Model): Model | nil
	for _, npc in self.npcs do
		if npc:GetCharacter() == character then
			return npc
		end
	end

	return nil
end

function NPCManager:OnScream(pivot: CFrame)
	for _, npc in self.npcs do
		local npcPivot = npc:GetPivot()
		if not npcPivot then
			continue
		end

		if (npcPivot.Position - pivot.Position).Magnitude <= 50 then
			npc:ScreamOn()
		end
	end
end

function NPCManager:OnSurrender(character: Model): boolean
	local npc = self:GetNPCFromCharacter(character)
	if not npc then
		return false
	end

	return npc:Surrender()
end

function NPCManager:CreateNPC(className: string, ...)
	local npc = require(ServerScriptService.classes.npcs[className]).new()
	npc:Spawn(...)

	table.insert(self.npcs, npc)
	return npc
end

function NPCManager:Destroy() end

return NPCManager
