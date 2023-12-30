local ReplicatedStorage = game:GetService("ReplicatedStorage")

local glovesDirectory = ReplicatedStorage.Gloves :: Folder

type LocalProperties = {
	CleanupOldGloves: (self: LocalProperties, viewmodelOrCharacter: Model) -> (),
	ApplyToViewmodel: (self: LocalProperties, viewmodel: Model, currentGloves: string) -> (),
	ApplyToCharacter: (self: LocalProperties, character: Model, currentGloves: string) -> (),
}

type Glove = BasePart & {
	GloveAttachment: Attachment,
}

type Arm = BasePart & {
	GloveAttachment: Attachment,
}

local Gloves: LocalProperties = {} :: LocalProperties

local gloveNamePrefix = "Gloves"
local leftGloveName = `{gloveNamePrefix}_Left`
local rightGloveName = `{gloveNamePrefix}_Right`

local function setGloveProperties(glove: Glove)
	glove.CanCollide = false
	glove.CanQuery = false
	glove.CanTouch = false
	glove.Anchored = false
end

local function applyGloves(glovesFolder: Folder, leftArm: Arm, rightArm: Arm): (Glove, Glove)
	local leftGlove: Glove, rightGlove: Glove

	local singleGlove = glovesFolder:FindFirstChild("Glove")
	if singleGlove then
		leftGlove = singleGlove
		rightGlove = singleGlove
	else
		leftGlove = glovesFolder:FindFirstChild("Left") :: Glove
		rightGlove = glovesFolder:FindFirstChild("Right") :: Glove
	end

	local leftGloveClone = leftGlove:Clone()
	local rightGloveClone = rightGlove:Clone()

	leftGloveClone.Name = leftGloveName
	rightGloveClone.Name = rightGloveName

	local leftWeld = Instance.new("WeldConstraint")
	local rightWeld = Instance.new("WeldConstraint")

	leftWeld.Parent = leftGloveClone
	leftWeld.Part1 = leftGloveClone

	rightWeld.Parent = rightGloveClone
	rightWeld.Part1 = rightGloveClone

	setGloveProperties(leftGloveClone)
	leftGloveClone:PivotTo(leftArm.GloveAttachment.WorldCFrame * leftGloveClone.GloveAttachment.CFrame:Inverse())
	leftWeld.Part0 = leftArm

	setGloveProperties(rightGloveClone)
	rightGloveClone:PivotTo(rightArm.GloveAttachment.WorldCFrame * rightGloveClone.GloveAttachment.CFrame:Inverse())
	rightWeld.Part0 = rightArm

	return leftGloveClone, rightGloveClone
end

local function getGlovesFolder(folderFor: "Viewmodel" | "Character", glovesName: string): Folder
	local glovesFolder = glovesDirectory:FindFirstChild(glovesName) :: Folder
	local scope = glovesFolder:FindFirstChild(folderFor)
	if not scope then
		error(`Couldn't find scope {folderFor} in {glovesName}`)
	end

	return scope
end

function Gloves:CleanupOldGloves(viewmodelOrCharacter: Model)
	local oldLeftGlove = viewmodelOrCharacter:FindFirstChild(leftGloveName) :: Glove
	if oldLeftGlove then
		oldLeftGlove:Destroy()
	end

	local oldRightGlove = viewmodelOrCharacter:FindFirstChild(rightGloveName) :: Glove
	if oldRightGlove then
		oldRightGlove:Destroy()
	end
end

function Gloves:ApplyToViewmodel(viewmodel: Model, currentGloves: string?)
	self:CleanupOldGloves(viewmodel)

	if not currentGloves then
		return
	end

	local glovesFolder = getGlovesFolder("Viewmodel", currentGloves)
	local leftGlove, rightGlove = applyGloves(
		glovesFolder,
		viewmodel:FindFirstChild("Left Arm") :: Arm,
		viewmodel:FindFirstChild("Right Arm") :: Arm
	)

	leftGlove.Parent = viewmodel
	rightGlove.Parent = viewmodel
end

function Gloves:ApplyToCharacter(character: Model, currentGloves: string?)
	self:CleanupOldGloves(character)

	if not currentGloves then
		return
	end

	local glovesFolder = getGlovesFolder("Character", currentGloves)
	local leftGlove, rightGlove = applyGloves(
		glovesFolder,
		character:FindFirstChild("Left Arm") :: Arm,
		character:FindFirstChild("Right Arm") :: Arm
	)

	leftGlove.Parent = character
	rightGlove.Parent = character
end

return Gloves
