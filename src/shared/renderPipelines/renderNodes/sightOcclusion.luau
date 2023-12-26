local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CurrentCamera = require(ReplicatedStorage.Shared.CurrentCamera)
local RenderPipelineTypes = require(ReplicatedStorage.Shared.types.RenderPipelineTypes)
local WeaponTypes = require(ReplicatedStorage.Shared.types.WeaponTypes)
local FindChildrenWithTag = require(ReplicatedStorage.Shared.util.FindChildrenWithTag)
local getAngleBetweenCFrames = require(ReplicatedStorage.Shared.util.getAngleBetweenCFrames)
local lerpNumber = require(ReplicatedStorage.Shared.util.lerpNumber)

local Move: RenderPipelineTypes.NodeClass = {} :: RenderPipelineTypes.NodeClass
Move.__index = Move

local maxAngle = 7
local hideSpeed = 30

type Projector = BasePart & {
	Hides: Model,
	Shows: Model,
	Container: ScreenGui & {
		ClippingFrame: CanvasGroup,
	},
}

function Move.new(): RenderPipelineTypes.NodeObject
	local self = setmetatable({}, Move)

	return self
end

function Move:PostUpdate(deltaTime: number, viewmodel: WeaponTypes.Viewmodel)
	local projectors = FindChildrenWithTag(viewmodel.weapon, "projector")
	for _, projector: Projector in projectors do
		local angle = getAngleBetweenCFrames(projector.CFrame, CurrentCamera.CFrame)

		for _, toHide in projector.Hides:GetChildren() do
			if not toHide:IsA("BasePart") then
				continue
			end

			toHide.Transparency = lerpNumber(toHide.Transparency, angle <= maxAngle and 1 or 0, hideSpeed * deltaTime)
			-- toHide.Transparency = angle <= maxAngle and 1 or 0
		end

		for _, toShow in projector.Shows:GetChildren() do
			if not toShow:IsA("BasePart") then
				continue
			end

			toShow.Transparency = lerpNumber(toShow.Transparency, angle <= maxAngle and 0 or 1, hideSpeed * deltaTime)
			-- toShow.Transparency = angle <= maxAngle and 0 or 1
		end
	end
end

return Move
