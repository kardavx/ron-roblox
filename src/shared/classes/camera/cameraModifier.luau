local ReplicatedStorage = game:GetService("ReplicatedStorage")

local cameraModifierConfig = require(ReplicatedStorage.Shared.configurations.cameraModifierConfig)
local GameTypes = require(ReplicatedStorage.Shared.types.GameTypes)

export type Class = {
	__index: Class,
	new: (modifies: "Raw" | "Default"?) -> Object,
	SumModifiers: (thatModify: "Raw" | "Default") -> CFrame,
	UpdateAll: (deltaTime: number) -> (),
	SetTarget: (self: Object, target: CFrame, alpha: number?) -> (),
	ResetTarget: (alpha: number?) -> (),
	Destroy: (self: Object) -> (),
} & GameTypes.ClientMethods<Object>

export type Object = typeof(setmetatable({} :: { target: CFrame, current: CFrame, alpha: number }, {} :: Class))

local CameraModifier: Class = {} :: Class
CameraModifier.__index = CameraModifier

local Modifiers: { Object } = {}

function CameraModifier.SumModifiers(thatModify: "Raw" | "Default")
	local summedCFrames = CFrame.identity

	for _, modifier in Modifiers do
		if modifier.modifies ~= thatModify then
			continue
		end

		summedCFrames *= modifier.current
	end

	return summedCFrames
end

function CameraModifier.new(modifies: "Raw" | "Default"?)
	local self = setmetatable({}, CameraModifier) :: Object

	self.modifies = modifies or "Default"
	self.alpha = cameraModifierConfig.defaultAlphaValue
	self.target = CFrame.identity
	self.current = CFrame.identity

	table.insert(Modifiers, self)

	return self
end

function CameraModifier.UpdateAll(deltaTime: number)
	for _, modifier in Modifiers do
		modifier:Update(deltaTime)
	end
end

function CameraModifier:SetTarget(target: CFrame, alpha: number?)
	self.target = target

	if alpha == 0 then
		self.current = self.target
	else
		self.alpha = alpha or cameraModifierConfig.defaultAlphaValue
	end
end

function CameraModifier:ResetTarget(alpha: number?)
	self.target = CFrame.identity

	if alpha == 0 then
		self.current = self.target
	else
		self.alpha = alpha or cameraModifierConfig.defaultAlphaValue
	end
end

function CameraModifier:Update(deltaTime: number)
	self.current = self.current:Lerp(self.target, self.alpha * deltaTime)
end

function CameraModifier:Destroy()
	self.current = self.target
	table.remove(Modifiers, table.find(Modifiers, self))
end

return CameraModifier
