type Class = {
	__index: Class,
	new: () -> (),
}

local attachmentHandler = {}
attachmentHandler.__index = attachmentHandler

return attachmentHandler
