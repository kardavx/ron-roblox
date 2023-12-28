local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.package.React)

local function useTime()
	local time, setTime = React.useBinding(tick())

	React.useEffect(function()
		local connection = RunService.RenderStepped:Connect(function()
			setTime(tick())
		end)

		return function()
			connection:Disconnect()
		end
	end)

	return time
end

return useTime
