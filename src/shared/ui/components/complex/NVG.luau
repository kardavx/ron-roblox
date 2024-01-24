local ContextActionService = game:GetService("ContextActionService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CurrentCamera = require(ReplicatedStorage.Shared.CurrentCamera)
local UITypes = require(ReplicatedStorage.Shared.types.UITypes)
local FullscreenFrame = require(ReplicatedStorage.Shared.ui.components.base.FullscreenFrame)
local useProducerAsState = require(ReplicatedStorage.Shared.ui.hook.useProducerAsState)
local useSpring = require(ReplicatedStorage.Shared.ui.hook.useSpring)
local useTime = require(ReplicatedStorage.Shared.ui.hook.useTime)
local lerpNumber = require(ReplicatedStorage.Shared.util.lerpNumber)
local Maid = require(ReplicatedStorage.package.Maid)
local React = require(ReplicatedStorage.package.React)

type Props = {
	common: UITypes.CommonProps,
}

local StaticImages = {
	"rbxassetid://7472792778",
	"rbxassetid://10757636219",
	"rbxassetid://520992855",
	"rbxassetid://10195656966",
	"rbxassetid://4689700119",
	"rbxassetid://9470950",
	"rbxassetid://3203623798",
	"rbxassetid://2510585515",
}

local function NVG(props: Props)
	local time = useTime()
	local nextStaticChangeTick, setNextStaticChangeTick = React.useBinding(tick())
	local currentStaticImagePos, setCurrentStaticImagePos = React.useBinding(1)

	local nvgBroughtDown = useProducerAsState(props.common.clientState, function(state)
		return state.nvgBroughtDown
	end)

	local nvgFactor, setNvgFactor, setNvgFactorPosition = useSpring({ initialValue = 1, speed = 20 })

	setNvgFactorPosition(0)
	setNvgFactor(1)

	React.useEffect(function()
		local maid = Maid.new()

		local container = Instance.new("Part")
		container.Parent = CurrentCamera
		container.Anchored = true
		container.CanCollide = false
		container.CanQuery = false
		container.CanTouch = false
		container.Size = Vector3.new(0.1, 0.1, 0.1)
		container.Transparency = 1

		if nvgBroughtDown then
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://376178316"
			sound.Parent = container

			maid:GiveTask(sound)
			sound:Play()
		end

		local nvgLight = Instance.new("PointLight")
		nvgLight.Parent = container
		nvgLight.Brightness = 0.1
		nvgLight.Shadows = true
		nvgLight.Range = 10
		nvgLight.Enabled = nvgBroughtDown

		local nvgColorCorrection = Instance.new("ColorCorrectionEffect")
		nvgColorCorrection.Name = "NVG"
		nvgColorCorrection.Brightness = 0
		nvgColorCorrection.Contrast = 0
		nvgColorCorrection.Saturation = 0
		nvgColorCorrection.TintColor = nvgBroughtDown and Color3.fromHex("#9effa4") or Color3.new(1, 1, 1)
		nvgColorCorrection.Parent = CurrentCamera

		ContextActionService:BindAction("enableNVG", function(_, inputState: Enum.UserInputState)
			if inputState ~= Enum.UserInputState.Begin then
				return
			end

			props.common.clientState.setNVGBroughtDown(not props.common.clientState:getState().nvgBroughtDown)
		end, false, Enum.KeyCode.N)

		maid:GiveTask(container)
		maid:GiveTask(nvgLight)
		maid:GiveTask(nvgColorCorrection)
		maid:GiveTask(RunService.RenderStepped:Connect(function(deltaTime: number)
			local desiredBrightness =
				lerpNumber(nvgBroughtDown and 5 or -3, nvgBroughtDown and 1 or 0, nvgFactor:getValue())
			local desiredContrast =
				lerpNumber(nvgBroughtDown and -2 or 2, nvgBroughtDown and 1 or 0, nvgFactor:getValue())
			local desiredCompensation =
				lerpNumber(nvgBroughtDown and 5 or -3, nvgBroughtDown and 1.35 or 0, nvgFactor:getValue())

			nvgColorCorrection.Brightness = lerpNumber(nvgColorCorrection.Brightness, desiredBrightness, 5 * deltaTime)
			nvgColorCorrection.Contrast = lerpNumber(nvgColorCorrection.Contrast, desiredContrast, 5 * deltaTime)
			Lighting.ExposureCompensation =
				lerpNumber(Lighting.ExposureCompensation, desiredCompensation, 5 * deltaTime)

			nvgColorCorrection.Saturation = nvgBroughtDown and -1 or 0
			container.CFrame = CurrentCamera.CFrame
		end))

		return function()
			maid:Destroy()
			ContextActionService:UnbindAction("enableNVG")
			Lighting.ExposureCompensation = 0
		end
	end)

	return React.createElement(FullscreenFrame, {
		BackgroundTransparency = 1,
		PaddingPx = 0,
	}, {
		React.createElement("ImageLabel", {
			Image = time:map(function(tick: number)
				if tick > nextStaticChangeTick:getValue() then
					setNextStaticChangeTick(tick + 0.02)
					setCurrentStaticImagePos(math.random(1, #StaticImages))
				end

				return StaticImages[currentStaticImagePos:getValue()]
			end),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ImageTransparency = 0.95,
			Size = UDim2.fromScale(1, 1),
			Visible = nvgBroughtDown,
			BackgroundTransparency = 1,
		}),

		React.createElement("ImageLabel", {
			Image = "rbxassetid://16074488698",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1.1, 1),
			ImageTransparency = 0.05,
			Visible = nvgBroughtDown,
			BackgroundTransparency = 1,
		}),

		React.createElement("Frame", {
			BackgroundTransparency = nvgFactor:map(function(factor: number)
				return factor
			end),
			BackgroundColor3 = Color3.new(),
			Size = UDim2.fromScale(1, 1),
		}),
	})
end

return NVG
