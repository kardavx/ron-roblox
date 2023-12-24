local ReplicatedStorage = game:GetService("ReplicatedStorage")

local cameraModifierConfig = require(ReplicatedStorage.Shared.configurations.cameraModifierConfig)
local OOPTypes = require(ReplicatedStorage.Shared.types.OOPTypes)
local lerpNumber = require(ReplicatedStorage.Shared.util.lerpNumber)

export type Class = {
	__index: Class,
	new: () -> Object,
	SumModifiers: () -> number,
	UpdateAll: (deltaTime: number) -> (),
	SetTarget: (self: Object, target: number, alpha: number?) -> (),
	SetEnabled: (self: Object, enabled: boolean) -> (),
	ResetTarget: (alpha: number?) -> (),
	Destroy: (self: Object) -> (),
} & OOPTypes.ClientClassMethods<Object>

export type Object = typeof(setmetatable(
	{} :: { target: number, current: number, enabled: boolean, alpha: number },
	{} :: Class
))

local FovModifier: Class = {} :: Class
FovModifier.__index = FovModifier

local Modifiers: { Object } = {}

function FovModifier.SumModifiers()
	local summedNumbers = 0

	for _, modifier in Modifiers do
		summedNumbers += modifier.current
	end

	return summedNumbers
end

function FovModifier.new()
	local self = setmetatable({}, FovModifier) :: Object

	self.alpha = cameraModifierConfig.defaultAlphaValue
	self.target = 0
	self.current = 0
	self.enabled = true

	table.insert(Modifiers, self)

	return self
end

function FovModifier.UpdateAll(deltaTime: number)
	for _, modifier in Modifiers do
		modifier:Update(deltaTime)
	end
end

function FovModifier:SetEnabled(enabled: boolean)
	self.enabled = enabled
end

function FovModifier:SetTarget(target: number, alpha: number?)
	self.target = target

	if alpha == 0 then
		self.current = self.target
	else
		self.alpha = alpha or cameraModifierConfig.defaultAlphaValue
	end
end

function FovModifier:ResetTarget(alpha: number?)
	self.target = CFrame.identity

	if alpha == 0 then
		self.current = self.target
	else
		self.alpha = alpha or cameraModifierConfig.defaultAlphaValue
	end
end

function FovModifier:Update(deltaTime: number)
	self.current = lerpNumber(self.current, (self.enabled == true and self.target or 0), self.alpha * deltaTime)
end

function FovModifier:Destroy()
	self.current = self.target
	table.remove(Modifiers, table.find(Modifiers, self))
end

return FovModifier
