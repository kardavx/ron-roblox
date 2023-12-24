return function<T>(className: string, properties: { [string]: any }?): Instance & T
	local instance = Instance.new(className) :: T & Instance

	if properties then
		for propertyName: string, propertyValue: any in properties do
			instance[propertyName] = propertyValue
		end
	end

	return instance :: T & Instance
end
