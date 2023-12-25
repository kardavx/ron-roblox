local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CurrentCamera = require(ReplicatedStorage.Shared.CurrentCamera)
local camera = require(ReplicatedStorage.Shared.classes.camera.camera)
local ClassBag = require(ReplicatedStorage.Shared.module.ClassBag)
local OOPTypes = require(ReplicatedStorage.Shared.types.OOPTypes)
local forEach = require(ReplicatedStorage.Shared.util.forEach)

type Projector = BasePart & {
	Container: SurfaceGui & {
		ClippingFrame: CanvasGroup & {
			UICorner: UICorner,
			[string]: ImageLabel,
		},
	},
}

type LocalProperties = {} & OOPTypes.ClientClassMethods<LocalProperties>

local Projectors: LocalProperties = {} :: LocalProperties

function Projectors:Update(deltaTime: number)
	local playerCamera = ClassBag:GetClass("camera", true) :: camera.Object

	forEach(CollectionService:GetTagged("projector"), function(projector: Projector)
		if not projector:IsDescendantOf(workspace) then
			return
		end

		forEach(projector.Container.ClippingFrame:GetChildren(), function(reticle)
			if not reticle:IsA("ImageLabel") then
				return
			end

			if reticle:GetAttribute("Scalable") == true then
				local size = math.clamp(CurrentCamera.FieldOfView / playerCamera.baseFov, 0, 1)
				print(size)
				local originalSize = reticle:GetAttribute("originalSize")
				reticle.Size = reticle.Size:Lerp(
					UDim2.fromOffset(originalSize.X.Offset * size, originalSize.Y.Offset * size),
					10 * deltaTime
				)
			end

			local distScale = projector.CFrame:PointToObjectSpace(CurrentCamera.CFrame.Position) / projector.Size / 4
			reticle.Position =
				reticle.Position:Lerp(UDim2.fromScale(0.5 - distScale.X / 2, 0.5 - distScale.Y), 10 * deltaTime)
		end)
	end)
end

return Projectors
