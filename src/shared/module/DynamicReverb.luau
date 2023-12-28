local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local LocalPlayer = require(ReplicatedStorage.Shared.LocalPlayer)
local dynamicReverbConfig = require(ReplicatedStorage.Shared.configurations.dynamicReverbConfig)

type LocalProperties = {
    Update: (self: LocalProperties, deltaTime: number) -> ()
}

local DynamicReverb: LocalProperties = {} :: LocalProperties
local currentRoom: BasePart?
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include

local function updateCurrentRoom(): BasePart?
    if not LocalPlayer.Character then return currentRoom end
    
    local roomParts: {BasePart} = {}

    overlapParams.FilterDescendantsInstances = {LocalPlayer.Character.PrimaryPart}

    for _,room in CollectionService:GetTagged("room") do
        local isColliding = #workspace:GetPartsInPart(room, overlapParams) > 0
        if isColliding then
            table.insert(roomParts, room)
        end
    end

    if #roomParts == 0 then
        return
    elseif #roomParts == 1 then
        return roomParts[1]
    else
        local biggestRoom, biggestSize
        for _,room in roomParts do
            if not biggestRoom or room.Size.Magnitude > biggestSize then
                biggestRoom = room
                biggestSize = room.Size.Magnitude
            end
        end
        return biggestRoom
    end
end

local function findCorrespondingReverb(sizeMagnitude: number): Enum.ReverbType
    local currentIndex = 1
    local reverbFound: Enum.ReverbType

    repeat
        local currentIndexConfig = dynamicReverbConfig.reverbsFromSize[currentIndex]
        
        if currentIndex == #dynamicReverbConfig.reverbsFromSize then
            reverbFound = dynamicReverbConfig.reverbsFromSize[#dynamicReverbConfig.reverbsFromSize].Reverb
            continue
        end
        
        if sizeMagnitude <= currentIndexConfig.MaxSize then
            reverbFound = currentIndexConfig.Reverb
            continue
        end

        currentIndex += 1
    until reverbFound ~= nil

    return reverbFound
end

local function setReverb(desiredReverb: Enum.ReverbType)
    if SoundService.AmbientReverb ~= desiredReverb then
        SoundService.AmbientReverb = desiredReverb
    end
end

function DynamicReverb:Update(deltaTime)
    currentRoom = updateCurrentRoom()

    if currentRoom then
        local sizeMagnitude = currentRoom.Size.Magnitude
        setReverb(findCorrespondingReverb(sizeMagnitude))
    else
        setReverb(dynamicReverbConfig.reverbOutside)
    end
end

return DynamicReverb