local TweenService = game:GetService("TweenService")
local function SingleUseTween(object: Instance, tweenInfo: TweenInfo, propertiesTable: { [string]: any })
	local tween = TweenService:Create(object, tweenInfo, propertiesTable)
	tween:Play()
	tween.Completed:Once(function()
		tween:Destroy()
		tween = nil
	end)
end

return SingleUseTween
