local ReplicatedStorage = game:GetService("ReplicatedStorage")

local prefabs = ReplicatedStorage:WaitForChild("Prefabs")

local NPC = {}
NPC.__index = NPC

function NPC.new(className: string, modelName: string, spawnCFrame: CFrame)
	local self = setmetatable({}, NPC)
	self.className = className
	self.modelName = modelName
	self.spawnCFrame = spawnCFrame

	self:Spawn(modelName, spawnCFrame)

	return self
end

function NPC:CreateCharacterModel(modelName: string): Model | nil
	local characterModel = prefabs.Characters:FindFirstChild(modelName)
	return characterModel and characterModel:Clone() or nil
end

function NPC:Spawn(modelName: string, spawnCFrame: CFrame): ()
	self.character = self:CreateCharacterModel(modelName)
	self.character.Parent = workspace

	self.character:PivotTo(spawnCFrame)
end

function NPC:Destroy(): () end

return NPC
