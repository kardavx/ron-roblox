local PathFinder = {}
PathFinder.__index = PathFinder

function PathFinder.new()
	local self = setmetatable({}, PathFinder)

	return self
end

function PathFinder:Destroy() end

return PathFinder
