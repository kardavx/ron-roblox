local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientPlayerData = require(ReplicatedStorage.Shared.module.ClientPlayerData)

local Figure = script.Parent
local Torso = Figure:WaitForChild("Torso")
local RightShoulder = Torso:WaitForChild("Right Shoulder")
local LeftShoulder = Torso:WaitForChild("Left Shoulder")
local RightHip = Torso:WaitForChild("Right Hip")
local LeftHip = Torso:WaitForChild("Left Hip")
local Humanoid = Figure:WaitForChild("Humanoid")
local pose = "Standing"

local function getRigScale()
	return 1
end

local currentWalk = ClientPlayerData.clientProducer:getState().crouching and "crouchWalk" or "walk"
local currentIdle = ClientPlayerData.clientProducer:getState().crouching and "crouchIdle" or "idle"

local crouchTransitionSpeed = 0.4

local currentAnim = ""
local currentAnimInstance = nil
local currentAnimTrack = nil
local currentAnimKeyframeHandler = nil
local currentAnimSpeed = 1.0
local animTable = {}
local animNames = {
	idle = {
		{ id = "http://www.roblox.com/asset/?id=180435571", weight = 10 },
	},
	crouchIdle = {
		{ id = "rbxassetid://15833237630", weight = 10 },
	},
	walk = {
		{ id = "http://www.roblox.com/asset/?id=180426354", weight = 10 },
	},
	crouchWalk = {
		{ id = "rbxassetid://15833228013", weight = 10 },
	},
	run = {
		{ id = "run.xml", weight = 10 },
	},
	jump = {
		{ id = "http://www.roblox.com/asset/?id=125750702", weight = 10 },
	},
	fall = {
		{ id = "http://www.roblox.com/asset/?id=180436148", weight = 10 },
	},
	climb = {
		{ id = "http://www.roblox.com/asset/?id=180436334", weight = 10 },
	},
	sit = {
		{ id = "http://www.roblox.com/asset/?id=178130996", weight = 10 },
	},
	toolnone = {
		{ id = "http://www.roblox.com/asset/?id=182393478", weight = 10 },
	},
	toolslash = {
		{ id = "http://www.roblox.com/asset/?id=129967390", weight = 10 },
		--				{ id = "slash.xml", weight = 10 }
	},
	toollunge = {
		{ id = "http://www.roblox.com/asset/?id=129967478", weight = 10 },
	},
	wave = {
		{ id = "http://www.roblox.com/asset/?id=128777973", weight = 10 },
	},
	point = {
		{ id = "http://www.roblox.com/asset/?id=128853357", weight = 10 },
	},
	dance1 = {
		{ id = "http://www.roblox.com/asset/?id=182435998", weight = 10 },
		{ id = "http://www.roblox.com/asset/?id=182491037", weight = 10 },
		{ id = "http://www.roblox.com/asset/?id=182491065", weight = 10 },
	},
	dance2 = {
		{ id = "http://www.roblox.com/asset/?id=182436842", weight = 10 },
		{ id = "http://www.roblox.com/asset/?id=182491248", weight = 10 },
		{ id = "http://www.roblox.com/asset/?id=182491277", weight = 10 },
	},
	dance3 = {
		{ id = "http://www.roblox.com/asset/?id=182436935", weight = 10 },
		{ id = "http://www.roblox.com/asset/?id=182491368", weight = 10 },
		{ id = "http://www.roblox.com/asset/?id=182491423", weight = 10 },
	},
	laugh = {
		{ id = "http://www.roblox.com/asset/?id=129423131", weight = 10 },
	},
	cheer = {
		{ id = "http://www.roblox.com/asset/?id=129423030", weight = 10 },
	},
}

-- 15833228013

-- Existance in this list signifies that it is an emote, the value indicates if it is a looping emote
local emoteNames =
	{ wave = false, point = false, dance1 = true, dance2 = true, dance3 = true, laugh = false, cheer = false }

function configureAnimationSet(name, fileList)
	if animTable[name] ~= nil then
		for _, connection in pairs(animTable[name].connections) do
			connection:disconnect()
		end
	end
	animTable[name] = {}
	animTable[name].count = 0
	animTable[name].totalWeight = 0
	animTable[name].connections = {}

	-- check for config values
	local config = script:FindFirstChild(name)
	if config ~= nil then
		--		print("Loading anims " .. name)
		table.insert(
			animTable[name].connections,
			config.ChildAdded:connect(function(child)
				configureAnimationSet(name, fileList)
			end)
		)
		table.insert(
			animTable[name].connections,
			config.ChildRemoved:connect(function(child)
				configureAnimationSet(name, fileList)
			end)
		)
		local idx = 1
		for _, childPart in pairs(config:GetChildren()) do
			if childPart:IsA("Animation") then
				table.insert(
					animTable[name].connections,
					childPart.Changed:connect(function(property)
						configureAnimationSet(name, fileList)
					end)
				)
				animTable[name][idx] = {}
				animTable[name][idx].anim = childPart
				local weightObject = childPart:FindFirstChild("Weight")
				if weightObject == nil then
					animTable[name][idx].weight = 1
				else
					animTable[name][idx].weight = weightObject.Value
				end
				animTable[name].count = animTable[name].count + 1
				animTable[name].totalWeight = animTable[name].totalWeight + animTable[name][idx].weight
				idx = idx + 1
			end
		end
	end

	-- fallback to defaults
	if animTable[name].count <= 0 then
		for idx, anim in pairs(fileList) do
			animTable[name][idx] = {}
			animTable[name][idx].anim = Instance.new("Animation")
			animTable[name][idx].anim.Name = name
			animTable[name][idx].anim.AnimationId = anim.id
			animTable[name][idx].weight = anim.weight
			animTable[name].count = animTable[name].count + 1
			animTable[name].totalWeight = animTable[name].totalWeight + anim.weight
			--			print(name .. " [" .. idx .. "] " .. anim.id .. " (" .. anim.weight .. ")")
		end
	end
end

-- Clear any existing animation tracks
-- Fixes issue with characters that are moved in and out of the Workspace accumulating tracks
local animator = if Humanoid then Humanoid:FindFirstChildOfClass("Animator") else nil
if animator then
	local animTracks = animator:GetPlayingAnimationTracks()
	for i, track in ipairs(animTracks) do
		track:Stop(0)
		track:Destroy()
	end
end

for name, fileList in pairs(animNames) do
	configureAnimationSet(name, fileList)
end

-- ANIMATION

-- declarations
local toolAnim = "None"
local toolAnimTime = 0

local jumpAnimTime = 0
local jumpAnimDuration = 0.3

local toolTransitionTime = 0.1
local fallTransitionTime = 0.3

-- functions

function stopAllAnimations()
	local oldAnim = currentAnim

	-- return to idle if finishing an emote
	if emoteNames[oldAnim] ~= nil and emoteNames[oldAnim] == false then
		oldAnim = currentIdle
	end

	currentAnim = ""
	currentAnimInstance = nil
	if currentAnimKeyframeHandler ~= nil then
		currentAnimKeyframeHandler:disconnect()
	end

	if currentAnimTrack ~= nil then
		currentAnimTrack:Stop()
		currentAnimTrack:Destroy()
		currentAnimTrack = nil
	end
	return oldAnim
end

function setAnimationSpeed(speed)
	if speed ~= currentAnimSpeed then
		currentAnimSpeed = speed
		currentAnimTrack:AdjustSpeed(currentAnimSpeed)
	end
end

function keyFrameReachedFunc(frameName)
	if frameName == "End" then
		local repeatAnim = currentAnim
		-- return to idle if finishing an emote
		if emoteNames[repeatAnim] ~= nil and emoteNames[repeatAnim] == false then
			repeatAnim = currentIdle
		end

		local animSpeed = currentAnimSpeed
		playAnimation(repeatAnim, 0.0, Humanoid)
		setAnimationSpeed(animSpeed)
	end
end

-- Preload animations
function playAnimation(animName, transitionTime, humanoid)
	local roll = math.random(1, animTable[animName].totalWeight)
	local idx = 1
	while roll > animTable[animName][idx].weight do
		roll = roll - animTable[animName][idx].weight
		idx = idx + 1
	end
	local anim = animTable[animName][idx].anim

	-- switch animation
	if anim ~= currentAnimInstance then
		if
			currentAnim == "crouchIdle"
			or currentAnim == "crouchWalk"
			or animName == "crouchIdle"
			or animName == "crouchWalk"
		then
			transitionTime = crouchTransitionSpeed
		end

		if currentAnimTrack ~= nil then
			currentAnimTrack:Stop(transitionTime)
			currentAnimTrack:Destroy()
		end

		currentAnimSpeed = 1.0

		-- load it to the humanoid; get AnimationTrack
		currentAnimTrack = humanoid:LoadAnimation(anim)
		currentAnimTrack.Priority = Enum.AnimationPriority.Core

		-- play the animation
		currentAnimTrack:Play(transitionTime)
		currentAnim = animName
		currentAnimInstance = anim

		-- set up keyframe name triggers
		if currentAnimKeyframeHandler ~= nil then
			currentAnimKeyframeHandler:disconnect()
		end
		currentAnimKeyframeHandler = currentAnimTrack.KeyframeReached:connect(keyFrameReachedFunc)
	end
end

ClientPlayerData.clientProducer:subscribe(function(state)
	return state.crouching
end, function(newValue: boolean)
	currentWalk = newValue and "crouchWalk" or "walk"
	currentIdle = newValue and "crouchIdle" or "idle"

	if currentAnim ~= currentWalk and currentAnim == "walk" or currentAnim == "crouchWalk" then
		playAnimation(currentWalk, 0.1, Humanoid)
	elseif currentAnim ~= currentIdle and currentAnim == "idle" or currentAnim == "crouchIdle" then
		playAnimation(currentIdle, 0.1, Humanoid)
	end
end)

local toolAnimName = ""
local toolAnimTrack = nil
local toolAnimInstance = nil
local currentToolAnimKeyframeHandler = nil

function toolKeyFrameReachedFunc(frameName)
	if frameName == "End" then
		--		print("Keyframe : ".. frameName)
		playToolAnimation(toolAnimName, 0.0, Humanoid)
	end
end

function playToolAnimation(animName, transitionTime, humanoid, priority)
	local roll = math.random(1, animTable[animName].totalWeight)
	local idx = 1
	while roll > animTable[animName][idx].weight do
		roll = roll - animTable[animName][idx].weight
		idx = idx + 1
	end
	local anim = animTable[animName][idx].anim

	if toolAnimInstance ~= anim then
		if toolAnimTrack ~= nil then
			toolAnimTrack:Stop()
			toolAnimTrack:Destroy()
			transitionTime = 0
		end

		-- load it to the humanoid; get AnimationTrack
		toolAnimTrack = humanoid:LoadAnimation(anim)
		if priority then
			toolAnimTrack.Priority = priority
		end

		-- play the animation
		toolAnimTrack:Play(transitionTime)
		toolAnimName = animName
		toolAnimInstance = anim

		currentToolAnimKeyframeHandler = toolAnimTrack.KeyframeReached:connect(toolKeyFrameReachedFunc)
	end
end

function stopToolAnimations()
	local oldAnim = toolAnimName

	if currentToolAnimKeyframeHandler ~= nil then
		currentToolAnimKeyframeHandler:disconnect()
	end

	toolAnimName = ""
	toolAnimInstance = nil
	if toolAnimTrack ~= nil then
		toolAnimTrack:Stop()
		toolAnimTrack:Destroy()
		toolAnimTrack = nil
	end

	return oldAnim
end

function onRunning(speed)
	speed /= getRigScale()

	if speed > 0.01 then
		playAnimation(currentWalk, 0.1, Humanoid)
		if currentAnimInstance then
			--  "crouchWalk" or "walk"
			if currentWalk == "crouchWalk" then
				setAnimationSpeed(speed / 3)
			else
				setAnimationSpeed(speed / 14.5)
			end
		end
		pose = "Running"
	else
		-- crouchTransitionSpeed
		if emoteNames[currentAnim] == nil then
			playAnimation(currentIdle, 0.1, Humanoid)
			pose = "Standing"
		end
	end
end

function onDied()
	pose = "Dead"
end

function onJumping()
	playAnimation("jump", 0.1, Humanoid)
	jumpAnimTime = jumpAnimDuration
	pose = "Jumping"
end

function onClimbing(speed)
	speed /= getRigScale()

	playAnimation("climb", 0.1, Humanoid)
	setAnimationSpeed(speed / 12.0)
	pose = "Climbing"
end

function onGettingUp()
	pose = "GettingUp"
end

function onFreeFall()
	if jumpAnimTime <= 0 then
		playAnimation("fall", fallTransitionTime, Humanoid)
	end
	pose = "FreeFall"
end

function onFallingDown()
	pose = "FallingDown"
end

function onSeated()
	pose = "Seated"
end

function onPlatformStanding()
	pose = "PlatformStanding"
end

function onSwimming(speed)
	if speed > 0 then
		pose = "Running"
	else
		pose = "Standing"
	end
end

function getTool()
	for _, kid in ipairs(Figure:GetChildren()) do
		if kid.className == "Tool" then
			return kid
		end
	end
	return nil
end

function getToolAnim(tool)
	for _, c in ipairs(tool:GetChildren()) do
		if c.Name == "toolanim" and c.className == "StringValue" then
			return c
		end
	end
	return nil
end

function animateTool()
	if toolAnim == "None" then
		playToolAnimation("toolnone", toolTransitionTime, Humanoid, Enum.AnimationPriority.Idle)
		return
	end

	if toolAnim == "Slash" then
		playToolAnimation("toolslash", 0, Humanoid, Enum.AnimationPriority.Action)
		return
	end

	if toolAnim == "Lunge" then
		playToolAnimation("toollunge", 0, Humanoid, Enum.AnimationPriority.Action)
		return
	end
end

local lastTick = 0

function move(time)
	local amplitude = 1
	local frequency = 1
	local deltaTime = time - lastTick
	lastTick = time

	local climbFudge = 0
	local setAngles = false

	if jumpAnimTime > 0 then
		jumpAnimTime = jumpAnimTime - deltaTime
	end

	if pose == "FreeFall" and jumpAnimTime <= 0 then
		playAnimation("fall", fallTransitionTime, Humanoid)
	elseif pose == "Seated" then
		playAnimation("sit", 0.5, Humanoid)
		return
	elseif pose == "Running" then
		playAnimation(currentWalk, 0.1, Humanoid)
	elseif
		pose == "Dead"
		or pose == "GettingUp"
		or pose == "FallingDown"
		or pose == "Seated"
		or pose == "PlatformStanding"
	then
		--		print("Wha " .. pose)
		stopAllAnimations()
		amplitude = 0.1
		frequency = 1
		setAngles = true
	end

	if setAngles then
		local desiredAngle = amplitude * math.sin(time * frequency)

		RightShoulder:SetDesiredAngle(desiredAngle + climbFudge)
		LeftShoulder:SetDesiredAngle(desiredAngle - climbFudge)
		RightHip:SetDesiredAngle(-desiredAngle)
		LeftHip:SetDesiredAngle(-desiredAngle)
	end

	-- Tool Animation handling
	local tool = getTool()
	if tool and tool:FindFirstChild("Handle") then
		local animStringValueObject = getToolAnim(tool)

		if animStringValueObject then
			toolAnim = animStringValueObject.Value
			-- message recieved, delete StringValue
			animStringValueObject.Parent = nil
			toolAnimTime = time + 0.3
		end

		if time > toolAnimTime then
			toolAnimTime = 0
			toolAnim = "None"
		end

		animateTool()
	else
		stopToolAnimations()
		toolAnim = "None"
		toolAnimInstance = nil
		toolAnimTime = 0
	end
end

-- connect events
Humanoid.Died:connect(onDied)
Humanoid.Running:connect(onRunning)
Humanoid.Jumping:connect(onJumping)
Humanoid.Climbing:connect(onClimbing)
Humanoid.GettingUp:connect(onGettingUp)
Humanoid.FreeFalling:connect(onFreeFall)
Humanoid.FallingDown:connect(onFallingDown)
Humanoid.Seated:connect(onSeated)
Humanoid.PlatformStanding:connect(onPlatformStanding)
Humanoid.Swimming:connect(onSwimming)

-- main program

-- initialize to idle
playAnimation(currentIdle, 0.1, Humanoid)
pose = "Standing"

while Figure.Parent ~= nil do
	local _, time = wait(0.1)
	move(time)
end
