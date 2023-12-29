local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = require(ReplicatedStorage.Shared.LocalPlayer)
local debug = require(ReplicatedStorage.Shared.classes.debug)
local ambienceConfig = require(ReplicatedStorage.Shared.configurations.ambienceConfig)
local chooseRandomFromArray = require(ReplicatedStorage.Shared.util.chooseRandomFromArray)
local Maid = require(ReplicatedStorage.package.Maid)

type LocalProperties = {
	Update: (self: LocalProperties, deltaTime: number) -> (),
}

type Place = "Inside" | "Outside"

local Ambience: LocalProperties = {} :: LocalProperties

local ambienceDebug = debug.new(UDim2.fromOffset(600, 200))
local avalilibleAmbients: { [Place]: { Sound } } = {}

local fadeingDebug: { string } = {}

local tweenJanitors: { [string]: Maid.Maid } = {}
local fadeTweenInfo = TweenInfo.new(ambienceConfig.FadeTime, Enum.EasingStyle.Linear)

local isInRoom: boolean
local currentAmbient: Sound?

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include

local function fetchAmbients()
	for _, place: Folder in SoundService.Ambients:GetChildren() do
		if not place:IsA("Folder") then
			continue
		end

		avalilibleAmbients[place.Name :: Place] = {}

		for _, ambient in place:GetChildren() do
			if not ambient:IsA("Sound") then
				continue
			end

			if tweenJanitors[ambient.Name] then
				error(`Sound name duplication, ambient names need to be unique for identification!`)
			end

			ambient:SetAttribute("targetVolume", ambient.Volume)
			ambient.Volume = 0
			ambient.Name = `{place.Name}/{ambient.Name}`
			tweenJanitors[ambient.Name] = Maid.new()
			table.insert(avalilibleAmbients[place.Name :: Place], ambient)
		end
	end
end

local function updateRoomState(): boolean
	if not LocalPlayer.Character then
		return isInRoom
	end

	overlapParams.FilterDescendantsInstances = { LocalPlayer.Character.PrimaryPart }

	for _, room in CollectionService:GetTagged("room") do
		local isColliding = #workspace:GetPartsInPart(room, overlapParams) > 0
		if isColliding then
			return true
		end
	end

	return false
end

local function fadeInSound(sound: Sound)
	local tweenJanitor = tweenJanitors[sound.Name]
	if not tweenJanitor then
		error(`Couldn't fade in {sound.Name} because it lacks a janitor!`)
	end

	tweenJanitor:DoCleaning()

	local debugId = `{sound.Name} [FADE-IN]`
	table.insert(fadeingDebug, debugId)

	if not sound.IsPlaying then
		sound:Play()
	end

	local fadeIn = TweenService:Create(sound, fadeTweenInfo, { Volume = sound:GetAttribute("targetVolume") :: number })
	fadeIn:Play()

	tweenJanitor:GiveTask(fadeIn.Completed:Connect(function()
		table.remove(fadeingDebug, table.find(fadeingDebug, debugId))
		tweenJanitor:DoCleaning()
	end))

	tweenJanitor:GiveTask(function()
		table.remove(fadeingDebug, table.find(fadeingDebug, debugId))
		fadeIn:Pause()
		fadeIn:Destroy()
	end)
end

local function fadeOutSound(sound: Sound)
	local tweenJanitor = tweenJanitors[sound.Name]
	if not tweenJanitor then
		error(`Couldn't fade out {sound.Name} because it lacks a janitor!`)
	end

	tweenJanitor:DoCleaning()

	if not sound.IsPlaying then
		return
	end

	local debugId = `{sound.Name} [FADE-OUT]`
	table.insert(fadeingDebug, debugId)

	local fadeOut = TweenService:Create(sound, fadeTweenInfo, { Volume = 0 })
	fadeOut:Play()

	tweenJanitor:GiveTask(fadeOut.Completed:Connect(function()
		table.remove(fadeingDebug, table.find(fadeingDebug, debugId))
		sound:Stop()
		tweenJanitor:DoCleaning()
	end))

	tweenJanitor:GiveTask(function()
		fadeOut:Pause()
		table.remove(fadeingDebug, table.find(fadeingDebug, debugId))
		fadeOut:Destroy()
	end)
end

local function setAmbient(place: "Inside" | "Outside")
	local placeAmbients = avalilibleAmbients[place]
	local choosenAmbient = chooseRandomFromArray(placeAmbients)
	fadeInSound(choosenAmbient)
	choosenAmbient.TimePosition = 0
	currentAmbient = choosenAmbient
end

function Ambience:Update(deltaTime)
	local previousRoomState = isInRoom
	isInRoom = updateRoomState()

	if isInRoom ~= previousRoomState then
		if currentAmbient then
			fadeOutSound(currentAmbient)
		end

		local place = (isInRoom and "Inside" or "Outside") :: "Inside" | "Outside"
		setAmbient(place)
	end

	ambienceDebug:LogMultilineMessage({
		`Ambience: {currentAmbient and currentAmbient.Name or "No ambience"}`,
		`FADES:`,
		table.unpack(fadeingDebug),
	})

	ambienceDebug:Update()
end

fetchAmbients()

return Ambience
