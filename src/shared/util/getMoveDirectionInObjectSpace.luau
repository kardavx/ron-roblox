local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = require(ReplicatedStorage.Shared.LocalPlayer)
local PlayerModule = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))

return function(): Vector3
	return PlayerModule:GetControls():GetMoveVector(true)
end
