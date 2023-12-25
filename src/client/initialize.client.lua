local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = require(ReplicatedStorage.Shared.LocalPlayer)
local client = require(ReplicatedStorage.Shared.classes.client)

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

local clientInstance = client.new()

RunService:BindToRenderStep("Update", Enum.RenderPriority.Camera.Value, function(deltaTime: number)
	clientInstance:Update(deltaTime)
end)

RunService:BindToRenderStep("PostUpdate", Enum.RenderPriority.Camera.Value + 1, function(deltaTime: number)
	clientInstance:PostUpdate(deltaTime)
end)

RunService:BindToRenderStep("Physics", Enum.RenderPriority.Character.Value + 1, function(deltaTime: number)
	clientInstance:UpdatePhysics(deltaTime)
end)

if LocalPlayer.Character then
	clientInstance:UpdateCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterRemoving:Connect(function()
	clientInstance:UpdateCharacter(nil)
end)

LocalPlayer.CharacterAdded:Connect(function(character: Model)
	clientInstance:UpdateCharacter(character)
end)
