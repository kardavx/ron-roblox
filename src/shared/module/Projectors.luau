local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CurrentCamera = require(ReplicatedStorage.Shared.CurrentCamera)
local camera = require(ReplicatedStorage.Shared.classes.camera.camera)
local getActualMouseDelta = require(ReplicatedStorage.Shared.functions.getActualMouseDelta)
local ClassBag = require(ReplicatedStorage.Shared.module.ClassBag)
local GameTypes = require(ReplicatedStorage.Shared.types.GameTypes)
local forEach = require(ReplicatedStorage.Shared.util.forEach)
local nonZeroSign = require(ReplicatedStorage.Shared.util.nonZeroSign)

type Projector = BasePart & {
	Container: SurfaceGui & {
		ClippingFrame: CanvasGroup & {
			UICorner: UICorner,
			[string]: ImageLabel,
		},
	},
}

type LocalProperties = {} & GameTypes.ClientMethods<LocalProperties>

local Projectors: LocalProperties = {} :: LocalProperties

function Projectors:PostUpdate(deltaTime: number)
	forEach(CollectionService:GetTagged("projector"), function(projector: Projector)
		if not projector:IsDescendantOf(workspace) then
			return
		end

		forEach(projector.Container.ClippingFrame:GetChildren(), function(reticle)
			if not reticle:IsA("ImageLabel") then
				return
			end

			-- if reticle:GetAttribute("Scalable") == true then
			-- 	local size = math.clamp(CurrentCamera.FieldOfView / playerCamera.baseFov, 0, 1)
			-- 	local originalSize = reticle:GetAttribute("originalSize")
			-- 	reticle.Size = reticle.Size:Lerp(
			-- 		UDim2.fromOffset(originalSize.X.Offset * size, originalSize.Y.Offset * size),
			-- 		10 * deltaTime
			-- 	)
			-- end

			local distScale = projector.CFrame:PointToObjectSpace(CurrentCamera.CFrame.Position) / projector.Size
			local smoothing = reticle:GetAttribute("SmoothingSpeed")
			if smoothing then
				reticle.Position =
					reticle.Position:Lerp(UDim2.fromScale(0.5 + distScale.X, 0.5 - distScale.Y), smoothing * deltaTime)
			else
				reticle.Position = UDim2.fromScale(0.5 + distScale.X, 0.5 - distScale.Y)
			end

			local lastProjectorPosition = reticle:GetAttribute("lastPosition")
			local projectorDelta = lastProjectorPosition and (reticle.AbsolutePosition - lastProjectorPosition) * 40
				or Vector2.zero

			if reticle:GetAttribute("Blurrable") == true then
				local originalSize = reticle:GetAttribute("originalSize")

				reticle.Size = UDim2.fromOffset(
					math.clamp(
						(originalSize.X.Offset * nonZeroSign(projectorDelta.X)) + projectorDelta.X,
						originalSize.X.Offset - 200,
						originalSize.X.Offset + 200
					),
					math.clamp(
						(originalSize.Y.Offset * nonZeroSign(projectorDelta.Y)) + projectorDelta.Y,
						originalSize.Y.Offset - 200,
						originalSize.Y.Offset + 200
					)
				)
			end

			reticle:SetAttribute("lastPosition", reticle.AbsolutePosition)
		end)
	end)
end

return Projectors
