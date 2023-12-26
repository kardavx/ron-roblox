local ReplicatedStorage = game:GetService("ReplicatedStorage")

local camera = require(ReplicatedStorage.Shared.classes.camera.camera)
local cameraModifier = require(ReplicatedStorage.Shared.classes.camera.cameraModifier)
local fovModifier = require(ReplicatedStorage.Shared.classes.camera.fovModifier)
local input = require(ReplicatedStorage.Shared.classes.input)
local GenericWeaponConfig = require(ReplicatedStorage.Shared.configurations.weapons.GenericWeaponConfig)
local createViewmodel = require(ReplicatedStorage.Shared.functions.weapon.createViewmodel)
local loadAnimations = require(ReplicatedStorage.Shared.functions.weapon.loadAnimations)
local ClassBag = require(ReplicatedStorage.Shared.module.ClassBag)
local SignalBag = require(ReplicatedStorage.Shared.module.SignalBag)
local bobbing = require(ReplicatedStorage.Shared.renderPipelines.renderNodes.bobbing)
local move = require(ReplicatedStorage.Shared.renderPipelines.renderNodes.move)
local obstruction = require(ReplicatedStorage.Shared.renderPipelines.renderNodes.obstruction)
local sway = require(ReplicatedStorage.Shared.renderPipelines.renderNodes.sway)
local tilt = require(ReplicatedStorage.Shared.renderPipelines.renderNodes.tilt)
local renderPipeline = require(ReplicatedStorage.Shared.renderPipelines.renderPipeline)
local OOPTypes = require(ReplicatedStorage.Shared.types.OOPTypes)
local WeaponConfigTypes = require(ReplicatedStorage.Shared.types.WeaponConfigTypes)
local WeaponTypes = require(ReplicatedStorage.Shared.types.WeaponTypes)
local anyAnimationPlaying = require(ReplicatedStorage.Shared.util.animations.anyAnimationPlaying)
local onAnimationEnded = require(ReplicatedStorage.Shared.util.animations.onAnimationEnded)
local playAnimation = require(ReplicatedStorage.Shared.util.animations.playAnimation)
local playAnimationIfNotPlaying = require(ReplicatedStorage.Shared.util.animations.playAnimationIfNotPlaying)
local stopAnimation = require(ReplicatedStorage.Shared.util.animations.stopAnimation)
local stopAnimations = require(ReplicatedStorage.Shared.util.animations.stopAnimations)
local deepClone = require(ReplicatedStorage.Shared.util.deepClone)
local Maid = require(ReplicatedStorage.package.Maid)
local Promise = require(ReplicatedStorage.package.Promise)

export type Class = {
	__index: Class,
	new: (config: WeaponConfigTypes.Config) -> Object,
	Equip: (self: Object) -> Promise.Promise,
	Unequip: (self: Object) -> Promise.Promise,
	Destroy: (self: Object) -> (),
	BindInput: (self: Object) -> (),
	CanDoAction: (self: Object, respect: RespectTable | "All") -> boolean,
	Reload: (self: Object) -> (),
	Shoot: (self: Object) -> boolean,
	UpdateSlide: (self: Object, forcePosition: boolean?) -> (),
	UpdateNextShootTick: (self: Object) -> (),
} & OOPTypes.ClientClassMethods<Object>

type RespectTable = { "Equip" | "Equipping" | "Reloading" | "LowReady" }

export type Object = typeof(setmetatable(
	{} :: {
		lowReady: boolean,
		equipping: boolean,
		equipped: boolean,
		reloading: boolean,
		shootRequest: boolean,

		targetAimOffset: CFrame,
		currentAimOffset: CFrame,

		renderPipeline: renderPipeline.Object,

		nextShootTick: number,

		camera: camera.Object,
		config: WeaponConfigTypes.Config,
		animations: { [WeaponConfigTypes.AnimationsUnion]: AnimationTrack },
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
		tilt,
		obstruction,
		bobbing,
		sway,
		move,
	})

	--// what the fuck is this state managment
	self.lowReady = false
	self.equipping = false
	self.equipped = false
	self.reloading = false
	self.shootRequest = false

	self.targetAimOffset = CFrame.identity
	self.currentAimOffset = CFrame.identity

	self.nextShootTick = tick()
	self.camera = ClassBag:GetClass("camera", true)

	self.fakeCameraModifier = cameraModifier.new()
	self.adsZoomModifier = fovModifier.new()

	self.janitor = Maid.new()
	self.inputJanitor = Maid.new()
	self.config = loadConfig(config)
	self.viewmodel = createViewmodel(config.ViewmodelName)
	self.animations = loadAnimations(config, self.viewmodel)

	self.janitor:GiveTask(self.viewmodel)

	self.janitor:GiveTask(function()
		self.fakeCameraModifier:Destroy()
		self.adsZoomModifier:Destroy()
	end)

	self.janitor:GiveTask(function()
		self.inputJanitor:Destroy()
	end)

	for _, animationTrack in self.animations do
		if type(animationTrack) == "table" then
			for _, singleTrack in animationTrack do
				self.janitor:GiveTask(function()
					singleTrack:Destroy()
				end)
			end
		else
			self.janitor:GiveTask(function()
				animationTrack:Destroy()
			end)
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
	end

	return true
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
			self.targetAimOffset = self.config.Offsets.Aim
			self.adsZoomModifier:SetTarget(GenericWeaponConfig.adsZoom, self.config.AimSpeed)
		else
			self.targetAimOffset = CFrame.identity
			self.adsZoomModifier:SetTarget(0, self.config.AimSpeed)
		end
	end)

	local lowReadyConnection = input.SubscribeToInput("LowReady", function(holding: boolean)
		if not self:CanDoAction({ "Equip", "Equipping", "Reloading" }) then
			return
		end

		self.lowReady = not self.lowReady
		SignalBag:Fire("LowReady", self.lowReady)
		if self.lowReady then
			playAnimation(self.animations.LowReady, 0.25)
		else
			stopAnimation(self.animations.LowReady, 0.25)
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
	end)
end

function Weapon:UpdateSlide(forcePosition: boolean?)
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
		elseif child:IsA("Sound") then
			child:Play()
		end
	end

	self.camera:Shove(Vector2.new(0, -self.config.RecoilPunch))

	self:UpdateSlide()

	return true
end

function Weapon:Equip()
	self.equipping = true
	return Promise.new(function(resolve)
		self.equipping = false
		self.equipped = true
		playAnimation(self.animations.Idle, 0)
		self:UpdateSlide()
		onAnimationEnded(self.animations.Equip, function()
			self:BindInput()
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

	onAnimationEnded(animation, function()
		self.config.Ammo = self.config.MaxAmmo
		self.config.Mags -= 1
		self.reloading = false
		self.adsZoomModifier:SetEnabled(true)
	end, 0)
end

function Weapon:Unequip()
	self.inputJanitor:DoCleaning()
	self.targetAimOffset = CFrame.identity
	self.adsZoomModifier:SetTarget(0, self.config.AimSpeed)

	return Promise.new(function(resolve)
		onAnimationEnded(self.animations.Unequip, function()
			stopAnimations(self.animations, 0)
			resolve()
			self.equipped = false
		end, 0)
	end)
end

function Weapon:Destroy()
	self.janitor:Destroy()
end

function Weapon:Update(deltaTime: number)
	if not self.viewmodel then
		return
	end

	if self.shootRequest then
		if self:CanDoAction({ "Equip", "Equipping", "Reload" }) and tick() >= self.nextShootTick then
			local shootSuccess = self:Shoot()

			if not shootSuccess then
				self.shootRequest = false
			end

			if self.config.FireMode == "Semi" then
				self.shootRequest = false
			end

			self:UpdateNextShootTick()
		elseif self.config.FireMode == "Semi" then
			self.shootRequest = false
		end
	end

	self.fakeCameraModifier:SetTarget(
		CFrame.new()
			:Lerp(self.viewmodel.HumanoidRootPart.FakeCamera.Transform, GenericWeaponConfig.headMovementModifier),
		0
	)

	self.currentAimOffset = self.currentAimOffset:Lerp(self.targetAimOffset, self.config.AimSpeed * deltaTime)

	if self.equipped and anyAnimationPlaying(self.animations) then
		self.viewmodel:PivotTo(self.camera.rawCameraCFrame)

		self.renderPipeline:PreUpdate(deltaTime, self.viewmodel)
		self.viewmodel:PivotTo(
			self.renderPipeline:Update(deltaTime, self.camera.rawCameraCFrame * self.currentAimOffset, self.viewmodel)
		)
		self.renderPipeline:PostUpdate(deltaTime, self.viewmodel)
	else
		self.viewmodel:PivotTo(CFrame.new(math.huge, math.huge, math.huge))
	end
end

return Weapon