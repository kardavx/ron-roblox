local ReplicatedStorage = game:GetService("ReplicatedStorage")

local camera = require(ReplicatedStorage.Shared.classes.camera.camera)
local cameraModifier = require(ReplicatedStorage.Shared.classes.camera.cameraModifier)
local fovModifier = require(ReplicatedStorage.Shared.classes.camera.fovModifier)
local input = require(ReplicatedStorage.Shared.classes.input)
local weaponSounds = require(ReplicatedStorage.Shared.classes.weaponSounds)
local ClientGenericWeaponConfig = require(ReplicatedStorage.Shared.configurations.weapons.ClientGenericWeaponConfig)
local createViewmodel = require(ReplicatedStorage.Shared.functions.weapon.createViewmodel)
local loadAnimationInformation = require(ReplicatedStorage.Shared.functions.weapon.loadAnimationInformation)
local loadAnimations = require(ReplicatedStorage.Shared.functions.weapon.loadAnimations)
local ClassBag = require(ReplicatedStorage.Shared.module.ClassBag)
local ClientPlayerData = require(ReplicatedStorage.Shared.module.ClientPlayerData)
local SignalBag = require(ReplicatedStorage.Shared.module.SignalBag)
local aim = require(ReplicatedStorage.Shared.renderPipelines.renderNodes.aim)
local bobbing = require(ReplicatedStorage.Shared.renderPipelines.renderNodes.bobbing)
local lean = require(ReplicatedStorage.Shared.renderPipelines.renderNodes.lean)
local move = require(ReplicatedStorage.Shared.renderPipelines.renderNodes.move)
local obstruction = require(ReplicatedStorage.Shared.renderPipelines.renderNodes.obstruction)
local scream = require(ReplicatedStorage.Shared.renderPipelines.renderNodes.scream)
local sightOcclusion = require(ReplicatedStorage.Shared.renderPipelines.renderNodes.sightOcclusion)
local sway = require(ReplicatedStorage.Shared.renderPipelines.renderNodes.sway)
local tilt = require(ReplicatedStorage.Shared.renderPipelines.renderNodes.tilt)
local renderPipeline = require(ReplicatedStorage.Shared.renderPipelines.renderPipeline)
local GameTypes = require(ReplicatedStorage.Shared.types.GameTypes)
local WeaponConfigTypes = require(ReplicatedStorage.Shared.types.WeaponConfigTypes)
local WeaponTypes = require(ReplicatedStorage.Shared.types.WeaponTypes)
local anyAnimationPlaying = require(ReplicatedStorage.Shared.util.animations.anyAnimationPlaying)
local onAnimationEnded = require(ReplicatedStorage.Shared.util.animations.onAnimationEnded)
local onCustomLengthAnimationEneded = require(ReplicatedStorage.Shared.util.animations.onCustomLengthAnimationEneded)
local playAnimation = require(ReplicatedStorage.Shared.util.animations.playAnimation)
local playAnimationIfNotPlaying = require(ReplicatedStorage.Shared.util.animations.playAnimationIfNotPlaying)
local scaleTrackToLength = require(ReplicatedStorage.Shared.util.animations.scaleTrackToLength)
local stopAnimation = require(ReplicatedStorage.Shared.util.animations.stopAnimation)
local stopAnimations = require(ReplicatedStorage.Shared.util.animations.stopAnimations)
local deepClone = require(ReplicatedStorage.Shared.util.deepClone)
local Bridgenet2 = require(ReplicatedStorage.package.Bridgenet2)
local Maid = require(ReplicatedStorage.package.Maid)
local Promise = require(ReplicatedStorage.package.Promise)

local weaponEquipBridge = Bridgenet2.ClientBridge("Weapon_Equip")
local weaponUnEquipBridge = Bridgenet2.ClientBridge("Weapon_Unequip")
local weaponShootBridge = Bridgenet2.ClientBridge("Weapon_Shoot")
local weaponAimBridge = Bridgenet2.ClientBridge("Weapon_Aim")
local weaponReloadBridge = Bridgenet2.ClientBridge("Weapon_Reload")

export type Class = {
	__index: Class,
	new: (config: WeaponConfigTypes.Config) -> Object,
	Equip: (self: Object) -> Promise.Promise,
	Unequip: (self: Object) -> Promise.Promise,
	Destroy: (self: Object) -> (),
	BindInput: (self: Object) -> (),
	CanDoAction: (self: Object, respect: RespectTable | "All") -> boolean,
	UpdateAimParts: (self: Object) -> (),
	Reload: (self: Object) -> (),
	Shoot: (self: Object) -> boolean,
	CheckMag: (self: Object) -> (),
	UpdateSlide: (self: Object, forcePosition: boolean?) -> (),
	UpdateNextShootTick: (self: Object) -> (),
	UpdateLowReady: (self: Object) -> (),
	AddLowReadyEnabler: (self: Object, enablerId: string) -> (),
	RemoveLowReadyEnabler: (self: Object, enablerId: string) -> (),
} & GameTypes.ClientMethods<Object>

type RespectTable = { "Equip" | "Equipping" | "Reloading" | "LowReady" }

export type Object = typeof(setmetatable(
	{} :: {
		lowReady: boolean,
		lowReadyEnablers: { string },
		equipping: boolean,
		equipped: boolean,
		reloading: boolean,
		magChecking: boolean,
		shootRequest: boolean,
		aiming: boolean,

		debug: { string },

		aimParts: { BasePart },
		currentAimPart: number,

		renderPipeline: renderPipeline.Object,

		nextShootTick: number,

		camera: camera.Object,
		config: WeaponConfigTypes.Config,
		animations: { [WeaponConfigTypes.AnimationsUnion]: AnimationTrack },
		animationInformation: {
			[WeaponConfigTypes.AnimationsUnion]: { [number]: { [string]: CFrame } }
				| { { [number]: { [string]: CFrame } } },
		},

		sounds: weaponSounds.Object,

		reloadSpeedScale: number,

		janitor: Maid.Maid,
		inputJanitor: Maid.Maid,

		fakeCameraModifier: cameraModifier.Class,
		adsZoomModifier: fovModifier.Class,

		viewmodel: WeaponTypes.Viewmodel,
	},
	{} :: Class
))

local Weapon: Class = {} :: Class
Weapon.__index = Weapon

local function loadConfig(config: WeaponConfigTypes.Config): WeaponConfigTypes.Config
	local clonedConfig = deepClone(config)
	clonedConfig.Animations = nil

	return clonedConfig
end

function Weapon.new(config: WeaponConfigTypes.Config)
	local self = setmetatable({}, Weapon) :: Object & Class

	if not config.Animations then
		error(`Weapon config is missing animations!`)
	end

	self.renderPipeline = renderPipeline.new({
		lean,
		aim,
		tilt,
		obstruction,
		bobbing,
		sway,
		move,
		scream,
		sightOcclusion,
	})

	--// what the fuck is this state managment
	self.lowReady = false
	self.lowReadyEnablers = {}
	self.equipping = false
	self.equipped = false
	self.reloading = false
	self.shootRequest = false
	self.aiming = false

	self.aimParts = {}
	self.currentAimPart = 1

	self.debug = {}

	self.nextShootTick = tick()
	self.camera = ClassBag:GetClass("camera", true)

	self.fakeCameraModifier = cameraModifier.new()
	self.adsZoomModifier = fovModifier.new()

	self.janitor = Maid.new()
	self.inputJanitor = Maid.new()
	self.config = loadConfig(config)
	self.viewmodel = createViewmodel(config.ViewmodelName)
	self.viewmodel:ScaleTo(self.config.ClientScale)

	self.sounds = weaponSounds.new(self.config.Sounds, self.viewmodel.PrimaryPart)
	self.animations = loadAnimations(config.Animations :: any, self.viewmodel, ClientGenericWeaponConfig.animationInfo)
	self.animationInformation = loadAnimationInformation(config)

	self.sounds:AttachToAnimations(self.animations)

	self.reloadSpeedScale = scaleTrackToLength(self.animations.Reload, self.config.ReloadLength)
	self.janitor:GiveTask(self.viewmodel)

	self.janitor:GiveTask(function()
		self.fakeCameraModifier:Destroy()
		self.adsZoomModifier:Destroy()
		self.inputJanitor:Destroy()
		self.sounds:Destroy()
	end)

	for _, animationTrack in self.animations do
		if type(animationTrack) == "table" then
			for _, singleTrack in animationTrack do
				self.janitor:GiveTask(singleTrack)
			end
		else
			self.janitor:GiveTask(animationTrack)
		end
	end

	return self
end

function Weapon:UpdateNextShootTick()
	self.nextShootTick = tick() + 1 / (self.config.FireRate / 60)
end

function Weapon:CanDoAction(respect: RespectTable | "All")
	if respect == "All" or table.find(respect, "Equip") then
		if not self.equipped then
			return false
		end
	end

	if respect == "All" or table.find(respect, "LowReady") then
		if self.lowReady then
			return false
		end
	end

	if respect == "All" or table.find(respect, "Equipping") then
		if self.equipping then
			return false
		end
	end

	if respect == "All" or table.find(respect, "Reloading") then
		if self.reloading then
			return false
		end

		if self.magChecking then
			return false
		end
	end

	return true
end

function Weapon:UpdateAimParts()
	local previousAimPart = self.aimParts[self.currentAimPart]

	local newAimParts = {}
	for _, aimPartName in self.config.AimParts do
		local aimPartBasePart = self.viewmodel.weapon:FindFirstChild(aimPartName)
		if not aimPartBasePart then
			error(`Couldn't find AimPart {aimPartName}, but it was defined in the config!`)
		end

		table.insert(newAimParts, aimPartBasePart)
	end

	local oldAimPartPos = table.find(newAimParts, previousAimPart)

	self.currentAimPart = oldAimPartPos or 1
	self.aimParts = newAimParts
end

function Weapon:UpdateLowReady()
	if not self.lowReady and self.aiming then
		return
	end

	self.lowReady = #self.lowReadyEnablers > 0
	SignalBag:Fire("LowReady", self.lowReady)

	if self.lowReady then
		playAnimation(self.animations.LowReady, 0.3)
	else
		stopAnimation(self.animations.LowReady, 0.3)
	end
end

function Weapon:AddLowReadyEnabler(enablerId: string)
	if table.find(self.lowReadyEnablers, enablerId) then
		return
	end

	table.insert(self.lowReadyEnablers, enablerId)
	self:UpdateLowReady()
end

function Weapon:RemoveLowReadyEnabler(enablerId: string)
	local foundEnabler = table.find(self.lowReadyEnablers, enablerId)
	if not foundEnabler then
		return
	end

	table.remove(self.lowReadyEnablers, foundEnabler)
	self:UpdateLowReady()
end

function Weapon:BindInput()
	local reloadConnection = input.SubscribeToInput("Reload", function()
		if not self:CanDoAction("All") then
			return
		end

		self:Reload()
	end)

	local shootConnection = input.SubscribeToInput("Shoot", function(holding: boolean)
		if not self:CanDoAction("All") then
			return
		end

		self.shootRequest = holding
	end)

	local aimConnection = input.SubscribeToInput("Aim", function(holding: boolean)
		if not self:CanDoAction({ "Equip" }) then
			return
		end

		if holding then
			if self.lowReady then
				return
			end
			self.sounds:Play("AimUp")
			self.aiming = true
			self.adsZoomModifier:SetTarget(self.config.AdsZoom, self.config.AimSpeed)
		else
			self.sounds:Play("AimDown")
			self.aiming = false
			self.adsZoomModifier:SetTarget(0, self.config.AimSpeed)
		end

		weaponAimBridge:Fire(self.aiming)
	end)

	local lowReadyConnection = input.SubscribeToInput("LowReady", function(holding: boolean)
		if not self:CanDoAction({ "Equip", "Equipping", "Reloading" }) then
			return
		end

		if table.find(self.lowReadyEnablers, "weapon") then
			self:RemoveLowReadyEnabler("weapon")
		else
			self:AddLowReadyEnabler("weapon")
		end
	end)

	local magCheckConnection = input.SubscribeToInput("MagCheck", function(holding: boolean)
		if not self:CanDoAction({ "Equip", "Equipping", "Reloading" }) then
			return
		end

		self:CheckMag()
	end)

	local addExternalLowReadyConnection = SignalBag:Connect("EnableLowReadyExternally", function(enablerId: string)
		self:AddLowReadyEnabler(enablerId)
	end)

	local removeExternalLowReadyConnection = SignalBag:Connect("DisableLowReadyExternally", function(enablerId: string)
		self:RemoveLowReadyEnabler(enablerId)
	end)

	if ClientPlayerData.clientProducer:getState().talkingThroughRadio == true then
		playAnimation(self.animations.Radio, 0.2)
	end

	local talkingThroughRadioConnection = ClientPlayerData.clientProducer:subscribe(function(state)
		return state.talkingThroughRadio
	end, function(newValue: boolean)
		if newValue then
			playAnimation(self.animations.Radio, 0.2)
		else
			stopAnimation(self.animations.Radio, 0.2)
		end
	end)

	SignalBag:Connect("Use", function()
		if not self:CanDoAction("All") then
			return
		end

		playAnimationIfNotPlaying(self.animations.Use)
	end)

	self.inputJanitor:GiveTask(function()
		reloadConnection:Destroy()
		shootConnection:Destroy()
		aimConnection:Destroy()
		lowReadyConnection:Destroy()
		addExternalLowReadyConnection:Destroy()
		removeExternalLowReadyConnection:Destroy()
		talkingThroughRadioConnection()
		magCheckConnection:Destroy()
	end)
end

function Weapon:UpdateSlide(forcePosition: boolean?)
	if not self.animations.Empty then
		return
	end

	if forcePosition == true then
		playAnimation(self.animations.Empty, 0)
		return
	end

	if forcePosition == false then
		stopAnimation(self.animations.Empty, 0)
		return
	end

	if self.config.Ammo == 0 then
		playAnimation(self.animations.Empty, 0)
	else
		stopAnimation(self.animations.Empty, 0)
	end
end

function Weapon:CheckMag()
	self.adsZoomModifier:SetEnabled(false)
	self.magChecking = true

	onAnimationEnded(self.animations.MagCheck, function()
		self.magChecking = false
		self.adsZoomModifier:SetEnabled(true)
	end)
end

function Weapon:Shoot(): boolean
	if self.config.Ammo == 0 then
		playAnimation(self.animations.ShootEmpty, 0)
		return false
	end

	stopAnimation(self.animations.Shoot, 0)
	playAnimation(self.animations.Shoot, 0)
	self.config.Ammo -= 1

	for _, child: Instance in self.viewmodel.weapon.Muzzle:GetChildren() do
		if child:IsA("ParticleEmitter") then
			child:Emit()
		end
		-- elseif child:IsA("Sound") then
		-- 	child:Play()
		-- end
	end

	self.camera:Shove(Vector2.new(0, -self.config.RecoilPunch))
	weaponShootBridge:Fire()
	self:UpdateSlide()

	return true
end

function Weapon:Equip()
	self.equipping = true
	weaponEquipBridge:Fire(self.config.ConfigName)
	return Promise.new(function(resolve)
		self.equipped = true
		playAnimation(self.animations.Idle, 0)
		self:UpdateSlide()
		onAnimationEnded(self.animations.Equip, function()
			self:BindInput()
			self.equipping = false
			self:UpdateLowReady()
			resolve()
		end, 0)
	end)
end

function Weapon:Unequip()
	self.inputJanitor:DoCleaning()
	self.aiming = false
	self.adsZoomModifier:SetTarget(0, self.config.AimSpeed)
	self.equipping = true
	self.lowReady = false
	weaponUnEquipBridge:Fire()
	SignalBag:Fire("LowReady", self.lowReady)

	return Promise.new(function(resolve)
		onAnimationEnded(self.animations.Unequip, function()
			stopAnimations(self.animations, 0)
			self.equipped = false
			self.equipping = false
			resolve()
		end, 0)
	end)
end

function Weapon:Reload()
	if self.config.Mags == 0 or self.config.Ammo == self.config.MaxAmmo then
		return
	end

	self.reloading = true
	local animation: AnimationTrack

	if self.config.Ammo == 0 then
		animation = self.animations.ReloadEmpty
		self:UpdateSlide(false)
	else
		animation = self.animations.Reload
	end

	self.adsZoomModifier:SetEnabled(false)
	weaponReloadBridge:Fire()

	animation:AdjustSpeed(self.reloadSpeedScale)
	onCustomLengthAnimationEneded(animation, function()
		self.config.Ammo = self.config.MaxAmmo
		self.config.Mags -= 1
		self.reloading = false
		self.adsZoomModifier:SetEnabled(true)
	end, self.config.ReloadLength, 0.1, nil, self.reloadSpeedScale)
end

function Weapon:Destroy()
	self.janitor:Destroy()
end

function Weapon:Update(deltaTime: number)
	local function formatAimParts(): { string }
		local names = {}
		for _, aimpart in self.aimParts do
			table.insert(names, aimpart.Name)
		end
		return names
	end

	self.debug = {
		`equipping: {self.equipping}`,
		`equipped: {self.equipped}`,
		`reloading: {self.reloading}`,
		`lowReady: {self.lowReady}`,
		`shootRequest: {self.shootRequest}`,
		`canDoAction: {self:CanDoAction("All")}`,
		`ammo: {self.config.Ammo}`,
		`maxAmmo: {self.config.MaxAmmo}`,
		`mags: {self.config.Mags}`,
		`aimParts: {table.concat(formatAimParts(), `,`)}`,
		`curentAimPart: {self.currentAimPart}`,
		`desiredAimPartName: {self.config.AimParts[self.currentAimPart] and self.config.AimParts[self.currentAimPart] or "None"}`,
		`currentAimPartName: {self.aimParts[self.currentAimPart] and self.aimParts[self.currentAimPart].Name or "None"}`,
	}

	if not self.viewmodel then
		return
	end

	if self.shootRequest then
		local tickElapsed = tick() >= self.nextShootTick
		local actionPermitted = self:CanDoAction({ "Equip", "Equipping", "Reload" })

		if actionPermitted and tickElapsed then
			local shootSuccess = self:Shoot()

			if not shootSuccess then
				self.shootRequest = false
			end

			if self.config.FireMode == "Semi" then
				self.shootRequest = false
			end

			self:UpdateNextShootTick()
		else
			if not actionPermitted or (self.config.FireMode == "Semi" and not tickElapsed) then
				self.shootRequest = false
			end
		end
	end

	self.fakeCameraModifier:SetTarget(
		CFrame.new()
			:Lerp(
				self.viewmodel.HumanoidRootPart.FakeCamera.Transform,
				ClientGenericWeaponConfig.headMovementMultiplier
			),
		0
	)

	self:UpdateAimParts()

	if self.equipped and anyAnimationPlaying(self.animations) then
		self.viewmodel:PivotTo(self.camera.rawCameraCFrame)

		self.renderPipeline:PreUpdate(
			deltaTime,
			self.viewmodel,
			self.aimParts[self.currentAimPart],
			self.aiming,
			self.animationInformation
		)

		self.renderPipeline:Update(
			deltaTime,
			self.camera.rawCameraCFrame,
			function(currentCFrame: CFrame)
				self.viewmodel:PivotTo(currentCFrame)
			end,
			self.viewmodel,
			self.animationInformation,
			self.aimParts[self.currentAimPart],
			self.aiming,
			self.config.ClientScale
		)

		self.renderPipeline:PostUpdate(deltaTime, self.viewmodel, self.aimParts[self.currentAimPart], self.aiming)
	else
		self.viewmodel:PivotTo(CFrame.new(math.huge, math.huge, math.huge))
	end
end

return Weapon
