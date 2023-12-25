local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.package.React)

-- export type customSpring = [Roact.Binding<number>, Hooks.MutableValueObject<number>, (value: number) => void];

local function serp(start, velocity, goal, stiffness, dampening, precision, alpha)
	alpha = math.min(alpha, 0.05) --to avoid having frametimes over this value, springs usually tend to go insane otherwise.

	local FSpring = -stiffness * (start - goal)
	local FDamper = -dampening * velocity
	local A = FSpring + FDamper

	local NewVelocity = velocity + A * alpha
	local NewPosition = start + NewVelocity * alpha

	if math.abs(NewVelocity) < precision and math.abs(start - NewPosition) < precision then
		return goal, 0
	end

	if
		NewPosition >= math.huge
		or NewVelocity >= math.huge
		or NewPosition ~= NewPosition
		or NewVelocity ~= NewVelocity
	then
		return start, velocity
	end

	return NewPosition, NewVelocity
end

type Props = {
	initialValue: number?,
}

return function(props: Props, deps: any)
	local target, setTarget = React.useBinding(props.initialValue)
	local position, setPosition = React.useBinding(props.initialValue)
	local velocity, setVelocity = React.useBinding(0)

	-- TODO spamienie tyle callbacków może prowadzić do problemów z wydajnością
	-- nie są dość duże ale to jest darmowe kilka fps a nam to jest potrzebne
	React.useEffect(function()
		local connection = RunService.RenderStepped:Connect(function()
			local newPosition, newVelocity =
				serp(position:getValue(), velocity:getValue(), target:getValue(), 20, 20, 0.001, 0.05)

			setPosition(newPosition)
			setVelocity(newVelocity)
		end)

		return function()
			connection:Disconnect()
		end
	end, deps)

	return position, setTarget
end
