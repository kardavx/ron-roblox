local function FindChildrenWithTag(model: Model, tagName: string): { Instance }
	local children = {}

	for _, child in model:GetChildren() do
		if child:HasTag(tagName) then
			table.insert(children, child)
		end
	end

	return children
end

return FindChildrenWithTag
