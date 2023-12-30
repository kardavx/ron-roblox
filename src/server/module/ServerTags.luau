local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local TagTypes = require(ReplicatedStorage.Shared.types.TagTypes)

local ServerTagsDirectory = ServerScriptService.tags

type LocalProperties = {
	Start: (self: LocalProperties) -> (),
}

local ServerTags: LocalProperties = {} :: LocalProperties
type Janitors = { [Instance]: { [string]: () -> () } }

local function loadTagDefinitions(): { TagTypes.TagDefinition }
	local definitions = {}

	for _, tagDefinition: ModuleScript in ServerTagsDirectory:GetChildren() do
		local requiredDefinition: TagTypes.TagDefinition = require(tagDefinition)
		table.insert(definitions, requiredDefinition)
	end

	return definitions
end

local function getTagsList(tagDefinitions: { TagTypes.TagDefinition }): { string }
	local tagsList = {}

	for _, tagDefinition in tagDefinitions do
		if not tagsList[tagDefinition.tagName] then
			table.insert(tagsList, tagDefinition.tagName)
		end
	end

	return tagsList
end

local function cleanupInstanceJanitorForTag(oldJanitors: Janitors, instance: Instance, tagName: string): Janitors
	if not oldJanitors[instance] then
		return oldJanitors
	end

	local janitors = table.clone(oldJanitors)
	janitors[instance] = table.clone(janitors[instance])

	if janitors[instance][tagName] then
		janitors[instance][tagName]()
		janitors[instance][tagName] = nil
	end

	return janitors
end

local function createInstanceJanitorForTag(
	oldJanitors: Janitors,
	cleanupFunction: () -> (),
	instance: Instance,
	tagName: string
): Janitors
	local janitors = table.clone(oldJanitors)

	if not janitors[instance] then
		janitors[instance] = {}
	else
		janitors[instance] = table.clone(janitors[instance])
	end

	if not janitors[instance][tagName] then
		janitors[instance][tagName] = cleanupFunction
	end

	return janitors
end

local function getDefinitionFromTagName(
	tagDefinitions: { TagTypes.TagDefinition },
	tagName: string
): TagTypes.TagDefinition?
	for _, tagDefinition in tagDefinitions do
		if tagDefinition.tagName == tagName then
			return tagDefinition
		end
	end

	return
end

function ServerTags:Start()
	local janitors: Janitors = {}
	local tagDefinitions = loadTagDefinitions()
	local tagsList = getTagsList(tagDefinitions)

	for _, tagName in tagsList do
		task.spawn(function()
			local definition = getDefinitionFromTagName(tagDefinitions, tagName)

			for _, taggedInstance: Instance in CollectionService:GetTagged(tagName) do
				task.spawn(function()
					local cleanupFunction = definition.onInstanceAdded(taggedInstance)

					local newJanitors = createInstanceJanitorForTag(janitors, cleanupFunction, taggedInstance, tagName)
					janitors = newJanitors
				end)
			end

			CollectionService:GetInstanceAddedSignal(tagName):Connect(function(taggedInstance: Instance)
				task.spawn(function()
					local cleanupFunction = definition.onInstanceAdded(taggedInstance)

					local newJanitors = createInstanceJanitorForTag(janitors, cleanupFunction, taggedInstance, tagName)
					janitors = newJanitors
				end)
			end)

			CollectionService:GetInstanceRemovedSignal(tagName):Connect(function(taggedInstance: Instance)
				task.spawn(function()
					janitors = cleanupInstanceJanitorForTag(janitors, taggedInstance, tagName)
				end)
			end)
		end)
	end
end

return ServerTags
