local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local PathFinder = {}
local PathFinders = {}
PathFinder.__index = PathFinder

function PathFinder:MoveToFinished()
	if self.connections.moveToFinished then
		self.connections.moveToFinished:Disconnect()
	end

	if self.humanoid then
		self.humanoid:Move(Vector3.zero)
	end

	self.events.moveToFinished:Fire()
	self.goal = nil
	self.blockRetry = 0
end

function PathFinder:GetGoalPosition(): Vector3
	return (typeof(self.goal) == "Vector3" and self.goal)
		or (typeof(self.goal) == "BasePart" and self.goal.CFrame.Position)
		or (typeof(self.goal) == "Model" and self.goal.PrimaryPart.CFrame.Position)
		or self.goal.Position
end

function PathFinder:FollowWaypoints()
	if self.connections.moveToFinished then
		self.connections.moveToFinished:Disconnect()
	end

	if not self.goal then
		return
	end

	pcall(function()
		self.agent.PrimaryPart:SetNetworkOwner(nil)
	end)

	self.connections.moveToFinished = self.humanoid.MoveToFinished:Once(function()
		local cFrame = self.agent.PrimaryPart:GetPivot()

		if self.lastCFrame and (cFrame.Position - self.lastCFrame.Position).Magnitude <= 0.1 then
			self.blockRetry += 1
		else
			self.blockRetry = 0
		end

		if self.blockRetry >= 4 then
			return self:MoveToFinished()
		end

		self.lastCFrame = cFrame

		self.currentWaypoint += 1
		self:FollowWaypoints()
	end)

	if self.currentWaypoint >= #self.waypoints then
		self:MoveToFinished(true)
		return
	end

	if self.humanoid then
		local waypoint = self.waypoints[self.currentWaypoint]

		self.humanoid:MoveTo(waypoint.Position)
	else
		self:MoveToFinished()
	end
end

function PathFinder:SetGoal(goal: Vector3): boolean
	self.goal = goal
	self.goalPosition = self:GetGoalPosition(self.goal)

	if
		not self.humanoid
		or self.humanoid.Health <= 0
		or self.humanoid:GetState() == Enum.HumanoidStateType.Freefall
	then
		return false
	end

	local success = pcall(function()
		self.path:ComputeAsync(self.agent.PrimaryPart.Position, self.goalPosition)
	end)

	if success and self.path.Status == Enum.PathStatus.Success then
		local waypoints = self.path:GetWaypoints()

		if #waypoints < 2 then
			return false
		end

		self.currentWaypoint = 2
		self.waypoints = waypoints

		self:FollowWaypoints()

		return true
	else
		self:MoveToFinished()
	end

	return false
end

function PathFinder.new(agent: Model, agentInfo: { any } | nil)
	local self = setmetatable({}, PathFinder)
	self.agent = agent
	self.humanoid = self.agent:FindFirstChildWhichIsA("Humanoid")
	self.path = PathfindingService:CreatePath({
		Costs = { DangerZone = math.huge },
	})
	self.blockRetry = 0

	self.events = {
		moveToFinished = Instance.new("BindableEvent"),
	}
	self.connections = {}

	table.insert(PathFinders, self)
	return self
end

function PathFinder.UpdateGoals()
	for _, pathFinder in PathFinders do
		if pathFinder.goal then
			pathFinder:SetGoal(pathFinder.goal)
		end
	end
end

function PathFinder:Destroy()
	table.remove(PathFinders, table.find(PathFinders, self))
end

RunService.PreSimulation:Connect(PathFinder.UpdateGoals)

return PathFinder
