local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RenderPipelineTypes = require(ReplicatedStorage.Shared.types.RenderPipelineTypes)

export type Class = {
	__index: Class,
	new: (nodeImplementations: { RenderPipelineTypes.NodeClass }) -> Object,
	Initialize: (self: Object, ...any) -> (),
	PreUpdate: (self: Object, deltaTime: number, ...any) -> (),
	Update: (self: Object, deltaTime: number, currentCFrame: CFrame, ...any) -> CFrame,
	PostUpdate: (self: Object, deltaTime: number, ...any) -> (),
}

export type Object = typeof(setmetatable(
	{} :: {
		nodes: { RenderPipelineTypes.NodeObject },
	},
	{} :: Class
))

local RenderPipeline: Class = {} :: Class
RenderPipeline.__index = RenderPipeline

function RenderPipeline.new(nodeImplementations: { RenderPipelineTypes.NodeClass })
	local self = setmetatable({}, RenderPipeline)

	self.nodes = {}
	for _, nodeImplementation in nodeImplementations do
		table.insert(self.nodes, nodeImplementation.new())
	end

	return self
end

function RenderPipeline:Initialize(...)
	local arguments = { ... }

	for _, nodeObject in self.nodes do
		if not nodeObject.Initialize then
			continue
		end

		task.spawn(function()
			nodeObject:Initialize(table.unpack(arguments))
		end)
	end
end

function RenderPipeline:PreUpdate(deltaTime: number, ...)
	local arguments = { ... }

	for _, nodeObject in self.nodes do
		if not nodeObject.PreUpdate then
			continue
		end

		task.spawn(function()
			nodeObject:PreUpdate(deltaTime, table.unpack(arguments))
		end)
	end
end

function RenderPipeline:Update(deltaTime: number, currentCFrame: CFrame, ...): CFrame
	local arguments = { ... }
	local finalCFrame = currentCFrame

	for _, nodeObject in self.nodes do
		if not nodeObject.Update then
			continue
		end

		task.spawn(function()
			finalCFrame = nodeObject:Update(deltaTime, finalCFrame, table.unpack(arguments))
		end)
	end

	return finalCFrame
end

function RenderPipeline:PostUpdate(deltaTime: number, ...)
	local arguments = { ... }

	for _, nodeObject in self.nodes do
		if not nodeObject.PostUpdate then
			continue
		end

		task.spawn(function()
			nodeObject:PostUpdate(deltaTime, table.unpack(arguments))
		end)
	end
end

return RenderPipeline
