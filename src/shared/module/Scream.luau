local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local input = require(ReplicatedStorage.Shared.classes.input)
local SignalBag = require(ReplicatedStorage.Shared.module.SignalBag)
local Bridgenet2 = require(ReplicatedStorage.package.Bridgenet2)

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local npcCharacter

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include

local lastScream = 0

input.SubscribeToInput("Arrest", function()
	if npcCharacter then
		Bridgenet2.ClientBridge("OnArrest"):Fire(npcCharacter)
	end
end)

input.SubscribeToInput("Scream", function()
	local now = os.clock()
	if now - lastScream < 1 then
		return
	end
	lastScream = now

	SignalBag:Fire("OnScream")
	Bridgenet2.ClientBridge("OnScream"):Fire()
end)

RunService.PreRender:Connect(function()
	local unitRay = mouse.UnitRay

	raycastParams.FilterDescendantsInstances = CollectionService:GetTagged("NPC")

	local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 100, raycastParams)
	if not raycastResult or not raycastResult.Instance then
		npcCharacter = nil
		return
	end

	local character = (raycastResult.Instance.Parent:HasTag("NPC") and raycastResult.Instance.Parent)
		or (raycastResult.Instance.Parent.Parent:HasTag("NPC") and raycastResult.Instance.Parent.Parent)
	npcCharacter = character
	if not character then
		npcCharacter = nil
		return
	end

	if not npcCharacter:GetAttribute("AreHandsUp") then
		Bridgenet2.ClientBridge("OnSurrender"):Fire(character)
	end
end)

return table.freeze({})
