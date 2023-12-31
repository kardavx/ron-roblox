local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SoundService = game:GetService("SoundService")
local VoicelineStorage = Instance.new("Folder")
VoicelineStorage.Name = "VoicelineStorage"
VoicelineStorage.Parent = SoundService

local tocData = require(ReplicatedStorage.Shared.data.tocData)
local ClientPlayerData = require(ReplicatedStorage.Shared.module.ClientPlayerData)
local chooseRandomFromArray = require(ReplicatedStorage.Shared.util.chooseRandomFromArray)
local Bridgenet2 = require(ReplicatedStorage.package.Bridgenet2)

type LocalProperties = {
	Voicelines: { [string]: { Sound } },
	IsCurrentlyPlaying: boolean,
	PlayVoiceline: (self: LocalProperties, voicelineName: string) -> (),
	Start: (self: LocalProperties) -> (),
}

local PlayTOCVoicelineBridge = Bridgenet2.ClientBridge("PlayTOCVoicelineBridge")

local function fetchVoicelines(): { [string]: { Sound } }
	local voicelines = {}

	for voicelineName, voicelineList in tocData do
		voicelines[voicelineName] = {}

		for _, voicelineData in voicelineList do
			local sound = Instance.new("Sound")
			sound.SoundId = `rbxassetid://{voicelineData.id}`
			sound.Name = voicelineName
			sound.Parent = VoicelineStorage
			sound:AddTag("voiceline")
			sound:SetAttribute("dialogId", voicelineData.dialogId)
			table.insert(voicelines[voicelineName], sound)
		end
	end

	return voicelines
end

local TOC: LocalProperties = {} :: LocalProperties

function TOC:PlayVoiceline(voicelineName: string)
	if not self.Voicelines or ClientPlayerData.clientProducer:getState().talkingThroughRadio == true then
		return
	end

	local desiredVoicelines = self.Voicelines[voicelineName]
	if not desiredVoicelines then
		error(`Attempted to play {voicelineName}, but couldn't find it!`)
	end

	local voiceLineToPlay = chooseRandomFromArray(desiredVoicelines)
	local prefixToPlay = chooseRandomFromArray(self.Voicelines.Prefix)

	ClientPlayerData.clientProducer.setTalkingThroughRadio(true)

	prefixToPlay:Play()
	prefixToPlay.Ended:Wait()
	voiceLineToPlay:Play()
	voiceLineToPlay.Ended:Once(function()
		ClientPlayerData.clientProducer.setTalkingThroughRadio(false)
	end)
end

function TOC:Start()
	self.Voicelines = fetchVoicelines()
end

PlayTOCVoicelineBridge:Connect(function(voicelineName: string)
	TOC:PlayVoiceline(voicelineName)
end)

return TOC
