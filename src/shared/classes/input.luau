local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InputTypes = require(ReplicatedStorage.Shared.types.InputTypes)
local GameTypes = require(ReplicatedStorage.Shared.types.GameTypes)
local deepClone = require(ReplicatedStorage.Shared.util.deepClone)
local Signal = require(ReplicatedStorage.package.Signal)

export type Class = {
	__index: Class,
	--- type checker freaks out with more than 2 arguments lol?
	inputChanged: Signal.Signal<...any>,
	currentlyHeldInputs: { string },
	new: (inputMap: InputTypes.InputMap) -> Object,
	SubscribeToInput: (inputName: string, func: (holding: boolean) -> ()) -> Signal.Connection,
	Destroy: (self: Object) -> (),
} & GameTypes.ClientMethods<Object>

export type Object = typeof(setmetatable({} :: { inputMap: InputTypes.InputMap }, {} :: Class))

local Input: Class = {
	inputChanged = Signal.new(),
	currentlyHeldInputs = {},
} :: Class
Input.__index = Input

local function registerActions(inputMap: InputTypes.InputMap)
	for inputName, inputInfo in inputMap do
		ContextActionService:BindAction(inputName, function(_, inputState: Enum.UserInputState)
			local inputStateToBoolean = inputState == Enum.UserInputState.Begin

			if inputInfo.inputType == "Hold" then
				if inputStateToBoolean then
					if not table.find(Input.currentlyHeldInputs, inputName) then
						table.insert(Input.currentlyHeldInputs, inputName)
					end
				else
					local foundInputIndex = table.find(Input.currentlyHeldInputs, inputName)
					if foundInputIndex then
						table.remove(Input.currentlyHeldInputs, foundInputIndex)
					end
				end
			end

			Input.inputChanged:Fire(inputName, inputStateToBoolean, inputInfo.inputType)
		end, false, inputInfo.keyCode)
	end
end

local function unregisterActions(inputMap: InputTypes.InputMap)
	for inputName, _ in inputMap do
		ContextActionService:UnbindAction(inputName)
	end
end

function Input.new(inputMap: InputTypes.InputMap)
	local self = setmetatable({}, Input)

	self.inputMap = deepClone(inputMap)
	registerActions(self.inputMap)

	return self
end

function Input.SubscribeToInput(inputName: string, func: (holding: boolean) -> ())
	if table.find(Input.currentlyHeldInputs, inputName) then
		func(true)
	end

	return Input.inputChanged:Connect(
		function(incomingInputName: string, incomingHeld: boolean, inputType: InputTypes.InputTypes)
			if incomingInputName ~= inputName then
				return
			end

			if inputType == "Click" and incomingHeld == true then
				func(true)
			elseif inputType == "Hold" then
				func(incomingHeld)
			end
		end
	)
end

function Input:Destroy()
	unregisterActions(self.inputMap)
end

return Input
