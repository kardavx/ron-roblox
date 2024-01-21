local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = require(ReplicatedStorage.Shared.LocalPlayer)
local CharacterTypes = require(ReplicatedStorage.Shared.types.CharacterTypes)
local Maid = require(ReplicatedStorage.package.Maid)
local React = require(ReplicatedStorage.package.React)
type Props = {}

local updateInterval = 0.1

local function getMotors(dummy: CharacterTypes.Dummy): { [string]: Motor6D }
	local motors = {}

	for _, motor: Instance in dummy:GetDescendants() do
		if not motor:IsA("Motor6D") then
			continue
		end

		motors[motor.Name] = motor :: Motor6D
	end

	return motors
end

local function getLimbs(dummy: CharacterTypes.Dummy): { [string]: BasePart }
	local limbs = {}

	for _, limb: Instance in dummy:GetChildren() do
		if not limb:IsA("BasePart") or limb.Transparency > 0 then
			continue
		end

		limbs[limb.Name] = limb
	end

	return limbs
end

local function Status()
	local nextUpdateTick, setNextUpdateTick = React.useBinding(tick())
	local ref = React.useRef(nil)

	React.useEffect(function()
		local maid = Maid.new()

		local worldModel = Instance.new("WorldModel")
		worldModel.Parent = ref.current

		local dummy = ReplicatedStorage.BaseDummy:Clone() :: CharacterTypes.Dummy
		dummy.Parent = worldModel
		dummy:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, math.pi, 0))

		local motors = getMotors(dummy)
		local limbs = getLimbs(dummy)

		local viewportCamera = Instance.new("Camera")
		viewportCamera.Parent = worldModel
		viewportCamera.CFrame = CFrame.new(0, -0.5, 15)
		viewportCamera.FieldOfView = 22

		ref.current.CurrentCamera = viewportCamera

		maid:GiveTask(dummy)
		maid:GiveTask(worldModel)
		maid:GiveTask(viewportCamera)
		maid:GiveTask(RunService.RenderStepped:Connect(function(deltaTime: number)
			if tick() >= nextUpdateTick:getValue() then
				setNextUpdateTick(tick() + updateInterval)

				for motorName, motor in motors do
					if not LocalPlayer.Character then
						motor.Transform = CFrame.identity
						continue
					end

					local motorInCharacter = LocalPlayer.Character:FindFirstChild(motorName, true)
					if not motorInCharacter then
						motor.Transform = CFrame.identity
						continue
					end

					motor.Transform = motorInCharacter.Transform
				end
			end

			if LocalPlayer.Character then
				local desiredColor = Color3.new(1.000000, 0.000000, 0.000000)
					:Lerp(Color3.new(1, 1, 1), LocalPlayer.Character.Humanoid.Health / 100)

				for _, limb in limbs do
					limb.Color = limb.Color:Lerp(desiredColor, 5 * deltaTime)
				end
			end
		end))

		return function()
			maid:Destroy()
		end
	end)

	return React.createElement("ViewportFrame", {
		ref = ref,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0.01, 0.97),
		Ambient = Color3.new(0.847059, 0.847059, 0.847059),
		LightColor = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0.2, 0.2),
	}, {
		React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 9 / 10,
		}),
	})
end

return Status
