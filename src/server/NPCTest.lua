local ServerScriptService = game:GetService("ServerScriptService")

local Civilian = require(ServerScriptService.classes.Civilian)
local NPC = require(ServerScriptService.classes.NPC)
local civilian = Civilian.new()
civilian:Spawn("Tyler", workspace:WaitForChild("Start").CFrame)

civilian:MoveTo(workspace:WaitForChild("Goal"))

task.wait(8)

civilian:HandsUp()
civilian:StopMoving()

task.wait(3)

civilian:OnKnees()

local NPCTest = {}

return NPCTest
