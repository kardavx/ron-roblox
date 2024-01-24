local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local CurrentCamera = require(ReplicatedStorage.Shared.CurrentCamera)
local RenderPipelineTypes = require(ReplicatedStorage.Shared.types.RenderPipelineTypes)
local WeaponTypes = require(ReplicatedStorage.Shared.types.WeaponTypes)
local FindChildrenWithTag = require(ReplicatedStorage.Shared.util.FindChildrenWithTag)
local getAngleBetweenCFrames = require(ReplicatedStorage.Shared.util.getAngleBetweenCFrames)
local Maid = require(ReplicatedStorage.package.Maid)

local Move: RenderPipelineTypes.NodeClass = {} :: RenderPipelineTypes.NodeClass
Move.__index = Move

local maxAngle = 7
local hideTweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

type Projector = BasePart & {
	Hides: Model,
	Shows: Model,
	Container: ScreenGui & {
		ClippingFrame: CanvasGroup,
	},
}

local stateToTransprency = {
	ToHide = {
		Hidden = 0,
		Shown = 1,
	},
	ToShow = {
		Hidden = 1,
		Shown = 0,
	},
}

function Move.new(): RenderPipelineTypes.NodeObject
	local self = setmetatable({}, Move)

	self.tweenState = ""
	self.tweenJanitor = Maid.new()

	return self
end

function Move:PostUpdate(deltaTime: number, viewmodel: WeaponTypes.Viewmodel)
	local projectors = FindChildrenWithTag(viewmodel.weapon, "projector")
	for _, projector: Projector in projectors do
		local angle = getAngleBetweenCFrames(projector.CFrame, CurrentCamera.CFrame)
		local currentState = (angle <= maxAngle) and "Shown" or "Hidden"

		if currentState ~= self.tweenState then
			self.tweenState = currentState

			self.tweenJanitor:DoCleaning()

			if projector:FindFirstChild("Hides") then
				for _, toHide in projector.Hides:GetChildren() do
					if not toHide:IsA("BasePart") then
						continue
					end

					toHide.Transparency = stateToTransprency.ToHide[currentState]
					local tween = TweenService:Create(
						toHide,
						hideTweenInfo,
						{ Transparency = stateToTransprency.ToHide[currentState] }
					)
					-- tween:Play()

					self.tweenJanitor:GiveTask(function()
						tween:Pause()
						tween:Destroy()
					end)
				end
			end

			if projector:FindFirstChild("Shows") then
				for _, toShow in projector.Shows:GetChildren() do
					if not toShow:IsA("BasePart") then
						continue
					end


					toShow.Transparency = stateToTransprency.ToShow[currentState]
					local tween = TweenService:Create(
						toShow,
						hideTweenInfo,
						{ Transparency = stateToTransprency.ToShow[currentState] }
					)
					-- tween:Play()

					self.tweenJanitor:GiveTask(function()
						tween:Pause()
						tween:Destroy()
					end)
				end
			end
		end

		-- for _, toHide in projector.Hides:GetChildren() do
		-- 	if not toHide:IsA("BasePart") then
		-- 		continue
		-- 	end

		-- 	toHide.Transparency = lerpNumber(toHide.Transparency, angle <= maxAngle and 1 or 0, hideSpeed * deltaTime)
		-- 	-- toHide.Transparency = angle <= maxAngle and 1 or 0
		-- end

		-- for _, toShow in projector.Shows:GetChildren() do
		-- 	if not toShow:IsA("BasePart") then
		-- 		continue
		-- 	end

		-- 	toShow.Transparency = lerpNumber(toShow.Transparency, angle <= maxAngle and 0 or 1, hideSpeed * deltaTime)
		-- 	-- toShow.Transparency = angle <= maxAngle and 0 or 1
		-- end
	end
end

return Move
