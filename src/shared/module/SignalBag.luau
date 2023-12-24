local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.package.Promise)
local Signal = require(ReplicatedStorage.package.Signal)

local SignalBag = {}
local Signals: { [string]: Signal.Signal<unknown> } = {}

local function createSignalIfMissing(signalId: string)
	if not Signals[signalId] then
		Signals[signalId] = Signal.new()
	end
end

function SignalBag:Fire(signalId: string, ...)
	createSignalIfMissing(signalId)

	local signal = Signals[signalId]
	signal:Fire(...)
end

function SignalBag:Connect(signalId: string, func: (...any) -> ())
	createSignalIfMissing(signalId)

	local signal = Signals[signalId]
	return signal:Connect(func)
end

function SignalBag:Once(signalId: string, func: (...any) -> ())
	createSignalIfMissing(signalId)

	local signal = Signals[signalId]
	return signal:Once(func)
end

function SignalBag:OnceAndExpectArguments(signalId: string, func: (...any) -> (), expected: { any })
	createSignalIfMissing(signalId)

	local signal = Signals[signalId]
	local connection

	connection = signal:Connect(function(...)
		local arguments = table.pack(...)
		for position, value in expected do
			if arguments[position] ~= value then
				return
			end
		end

		connection:Disconnect()
		func(...)
	end)
end

function SignalBag:ConnectAndExpectArguments(signalId: string, func: (...any) -> (), expected: { any })
	createSignalIfMissing(signalId)

	local signal = Signals[signalId]
	return signal:Connect(function(...)
		local arguments = table.pack(...)
		for position, value in expected do
			if arguments[position] ~= value then
				return
			end
		end

		func(...)
	end)
end

--- [YIELDS]
function SignalBag:Wait(signalId: string)
	createSignalIfMissing(signalId)

	local signal = Signals[signalId]
	return signal:Wait()
end

function SignalBag:WaitAndExpectArguments(signalId: string, expected: { any })
	createSignalIfMissing(signalId)

	local signal = Signals[signalId]
	local waitPromise = Promise.new(function(resolve, reject)
		local arguments = table.pack(signal:Wait())
		for position, value in expected do
			if arguments[position] ~= value then
				reject("Argument mismatch!")
				return
			end
		end
		resolve(table.unpack(arguments))
	end)

	return Promise.retry(waitPromise, 5)
end

return SignalBag
