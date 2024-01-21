export type Class = {
	__index: Class,
	new: (origin: Vector3, direction: Vector3) -> Object,
}

export type ObjectProperties = {
	test: string,
}

export type Object = typeof(setmetatable({} :: ObjectProperties, {} :: Class))

local Projectile: Class = {} :: Class
Projectile.__index = Projectile

function Projectile.new(origin: Vector3, direction: Vector3)
	local self: Object = setmetatable({} :: ObjectProperties, Projectile)

	return self
end

return Projectile
