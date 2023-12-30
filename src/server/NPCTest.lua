local ServerScriptService = game:GetService("ServerScriptService")

local NPCManager = require(ServerScriptService.classes.NPCManager)
local Scream = require(ServerScriptService.module.Scream)
NPCManager.new()

task.delay(3, function()
	local npc = NPCManager:CreateNPC("Civilian", "Tonya", workspace:WaitForChild("Start").CFrame)

	npc:MoveTo(workspace.Goal)
end)

local NPCTest = {}

return NPCTest
