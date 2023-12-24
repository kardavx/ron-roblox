export type Class = {
	__index: Class,
	new: (amplitude: number, frequency: number, phase: number?, multiplier: number?) -> Object,
	SetFrequency: (self: Object, frequency: number) -> (),
	SetAmplitude: (self: Object, amplitude: number) -> (),
	Update: () -> number,
}

export type Object = typeof(setmetatable(
	{} :: {
		amplitude: number,
		frequency: number,
		phase: number,
		multiplier: number,
	},
	{} :: Class
))

local Sine: Class = {} :: Class
Sine.__index = Sine

function Sine.new(amplitude: number, frequency: number, phase: number?, multiplier: number?): Object
	local self = setmetatable({}, Sine)

	self.amplitude = amplitude
	self.frequency = frequency
	self.phase = phase or 0
	self.multiplier = multiplier or 0.1

	return self
end

function Sine:SetFrequency(frequency: number): ()
	if frequency == self.frequency then
		return
	end

	local currentTick = os.clock()
	local oldArgument = self.frequency * currentTick + self.phase
	self.frequency = frequency
	self.phase = oldArgument - self.frequency * currentTick
end

function Sine:SetAmplitude(amplitude: number): ()
	self.amplitude = amplitude
end

-- return this.amplitude * math.sin(os.clock() * this.frequency + this.phase) * this.multiplier

function Sine:Update(): number
	return self.amplitude * math.sin(os.clock() * self.frequency + self.phase) * self.multiplier
end

return Sine
