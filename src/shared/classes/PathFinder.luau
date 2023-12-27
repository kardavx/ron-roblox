local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")

local PathFinder = {}
local PathFinders = {}
PathFinder.__index = PathFinder

function PathFinder:MoveToFinished(success: boolean)
	for _, connection in self.connections do
		connection:Disconnect()
	end

	if success then
		self.events.moveToFinished:Fire()
		self.goal = nil
	end
end

function PathFinder:GetGoalPosition(): Vector3
	return (typeof(self.goal) == "Vector3" and self.goal)
		or (typeof(self.goal) == "BasePart" and self.goal.CFrame.Position)
		or (typeof(self.goal) == "Model" and self.goal.PrimaryPart.CFrame.Position)
		or self.goal.Position
end

function PathFinder:SetGoal(goal: Vector3): boolean
	self.goal = goal
	self.goalPosition = self:GetGoalPosition(self.goal)
	local humanoid = self.agent and self.agent:FindFirstChildWhichIsA("Humanoid")

	if not humanoid or humanoid.Health <= 0 or humanoid:GetState() == Enum.HumanoidStateType.Freefall then
		return false
	end

	local success = pcall(function()
		self.path:ComputeAsync(self.agent.PrimaryPart.Position, self.goalPosition)
	end)

	if success and self.path.Status == Enum.PathStatus.Success then
		self.waypoints = self.path:GetWaypoints()

		if #self.waypoints < 2 then
			return false
		end

		pcall(function()
			self.agent.PrimaryPart:SetNetworkOwner(nil)
		end)

		self.currentWaypoint = 2

		self.connections.moveToFinished = humanoid.MoveToFinished:Once(function()
			self:MoveToFinished()
		end)

		if humanoid then
			humanoid:MoveTo(self.waypoints[self.currentWaypoint].Position)
		elseif #self.waypoints == 2 then
			self:MoveToFinished()
		else
			self:MoveToFinished()
		end

		if self.currentWaypoint == #self.waypoints then
			self:MoveToFinished(true)
		end

		return true
	end

	return false
end

function PathFinder.new(agent: Model, agentInfo: { any } | nil)
	local self = setmetatable({}, PathFinder)
	self.agent = agent
	self.path = PathfindingService:CreatePath(agentInfo or {
		AgentRadius = 3,
		AgentHeight = 6,
		AgentCanJump = false,
		Costs = {
			Water = 20,
		},
	})

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
