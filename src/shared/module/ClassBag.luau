local ReplicatedStorage = game:GetService("ReplicatedStorage")
local camera = require(ReplicatedStorage.Shared.classes.camera.camera)
local GameTypes = require(ReplicatedStorage.Shared.types.GameTypes)
local mergeDictionaries = require(ReplicatedStorage.Shared.util.mergeDictionaries)

type UnknownClasses = { [string]: GameTypes.UnknownObject }

type Classes = {
	camera: camera.Object,
} & UnknownClasses

export type LocalProperties = {
	classes: Classes,
	classesAdded: boolean,
	AddToBag: (self: LocalProperties, classes: UnknownClasses) -> (),
	ReplaceBag: (self: LocalProperties, classes: UnknownClasses) -> (),
	GetClass: <T>(self: LocalProperties, className: string, expect: boolean?) -> T & GameTypes.UnknownObject,
	ClearBag: (self: LocalProperties) -> (),
}

local ClassBag: LocalProperties = {
	classes = {},
} :: LocalProperties

function ClassBag:GetClass<T>(className: string, expect: boolean?): T & GameTypes.UnknownObject
	if not self.classes[className] then
		if expect then
			local waitingStartTick = tick()

			repeat
				if tick() - waitingStartTick > 5 then
					warn(`Infinite yield possible at ClassBag/{className} (Waited for more than 5 seconds)`)
				end

				task.wait()
			until self.classes[className]
		else
			error(`couldn't find className {className}`)
		end
	end

	return self.classes[className] :: T & GameTypes.UnknownObject
end

function ClassBag:AddToBag(classes: UnknownClasses)
	self.classes = mergeDictionaries(table.clone(self.classes), classes)
end

--- Used only with client.luau
function ClassBag:ReplaceBag(classes: UnknownClasses)
	self:ClearBag()
	self.classes = table.clone(classes)
end

function ClassBag:ClearBag()
	for className, _ in self.classes do
		self.classes[className] = nil
	end

	self.classesAdded = false
end

return ClassBag
