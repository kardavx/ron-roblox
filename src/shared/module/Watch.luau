local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WatchDirectory = ReplicatedStorage.Watches :: Folder

type LocalProperties = {
	currentWatch: string,
	SetCurrentWatch: (self: LocalProperties, WatchName: string) -> (),
	ApplyToViewmodel: (self: LocalProperties, viewmodel: Model) -> (),
	CleanupOldWatch: (self: LocalProperties, viewmodelOrCharacter: Model) -> (),
	ApplyToCharacter: (self: LocalProperties, character: Model) -> (),
}

type Watch = BasePart & {
	WatchAttachment: Attachment,
}

type Arm = BasePart & {
	WatchAttachment: Attachment,
}

local Watch: LocalProperties = {} :: LocalProperties

local watchName = "Watch"

local function setWatchProperties(glove: Watch)
	glove.CanCollide = false
	glove.CanQuery = false
	glove.CanTouch = false
	glove.Anchored = false
end

local function applyWatch(WatchFolder: Folder, leftArm: Arm): Watch
	local watch = WatchFolder:FindFirstChild("Watch")

	local watchClone = watch:Clone()
	watchClone.Name = watchName

	local weld = Instance.new("WeldConstraint")
	weld.Parent = watchClone
	weld.Part1 = watchClone

	setWatchProperties(watchClone)
	watchClone:PivotTo(leftArm.WatchAttachment.WorldCFrame * watchClone.WatchAttachment.CFrame:Inverse())
	weld.Part0 = leftArm

	return watchClone
end

local function getWatchFolder(folderFor: "Viewmodel" | "Character", WatchName: string): Folder
	local WatchFolder = WatchDirectory:FindFirstChild(WatchName) :: Folder
	local scope = WatchFolder:FindFirstChild(folderFor)
	if not scope then
		error(`Couldn't find scope {folderFor} in {WatchName}`)
	end

	return scope
end

function Watch:SetCurrentWatch(WatchName: string)
	if not WatchDirectory:FindFirstChild(WatchName) then
		error(`Given Watch have no storage specified!`)
	end

	self.currentWatch = WatchName
end

function Watch:CleanupOldWatch(viewmodelOrCharacter: Model)
	local oldWatch = viewmodelOrCharacter:FindFirstChild(watchName) :: Watch
	if oldWatch then
		oldWatch:Destroy()
	end
end

function Watch:ApplyToViewmodel(viewmodel: Model)
	self:CleanupOldWatch(viewmodel)

	if not self.currentWatch then
		return
	end

	local WatchFolder = getWatchFolder("Viewmodel", self.currentWatch)
	local watch = applyWatch(WatchFolder, viewmodel:FindFirstChild("Left Arm") :: Arm)

	watch.Parent = viewmodel
end

function Watch:ApplyToCharacter(character: Model)
	self:CleanupOldWatch(character)

	if not self.currentWatch then
		return
	end

	local WatchFolder = getWatchFolder("Character", self.currentWatch)
	local watch = applyWatch(WatchFolder, character:FindFirstChild("Left Arm") :: Arm)

	watch.Parent = character
end

return Watch
