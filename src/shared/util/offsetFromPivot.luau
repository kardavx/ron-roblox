-- export const offsetFromPivot = (cFrame: CFrame, pivot: CFrame, offset: CFrame) => {
-- 	const pivotToCFrameOffset = pivot.ToObjectSpace(cFrame);

-- 	pivot = pivot.mul(offset);
-- 	return pivot.mul(pivotToCFrameOffset);
-- };

local function offsetFromPivot(CFrame: CFrame, pivot: CFrame, offset: CFrame)
	local pivotToCFrameOffset = pivot:ToObjectSpace(CFrame)

	pivot = pivot * offset
	return pivot * pivotToCFrameOffset
end

return offsetFromPivot
