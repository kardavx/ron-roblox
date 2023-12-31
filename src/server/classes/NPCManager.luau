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

function NPCManager:OnScream(player: Player, pivot: CFrame)
	for _, npc in self.npcs do
		local npcPivot = npc:GetPivot()
		if not npcPivot then
			continue
		end

		if (npcPivot.Position - pivot.Position).Magnitude <= 50 then
			npc:ScreamOn(player, pivot)
		end
	end
end

function NPCManager:IsPlayerInNPCFOV(player: Player, npc): boolean
	local playerCharacter = player.Character
	local head = playerCharacter and playerCharacter:FindFirstChild("Head")
	local headPivot = head and head:GetPivot()
	if not headPivot then
		return false
	end

	if not npc:IsInFov(headPivot.Position) then
		return false
	end

	return true
end

function NPCManager:OnSurrender(player: Player, character: Model): boolean
	local npc = self:GetNPCFromCharacter(character)
	if not npc then
		return false
	end

	if not self:IsPlayerInNPCFOV(player, npc) then
		return false
	end

	return npc:Surrender()
end

function NPCManager:OnArrest(player: Player, character: Model)
	local npc = self:GetNPCFromCharacter(character)
	if not npc then
		return false
	end

	if self:IsPlayerInNPCFOV(player, npc) then
		return false
	end

	if not npc:IsSurrended() then
		return false
	end

	return npc:Arrest(player)
end

function NPCManager:CreateNPC(className: string, ...)
	local npc = require(ServerScriptService.classes.npcs[className]).new()
	npc:Spawn(...)

	table.insert(self.npcs, npc)
	return npc
end

function NPCManager:Destroy() end

return NPCManager
