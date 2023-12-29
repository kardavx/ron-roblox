local ServerScriptService = game:GetService("ServerScriptService")

local NPCManager = require(ServerScriptService.classes.NPCManager)
local Scream = require(ServerScriptService.module.Scream)
NPCManager.new()

local npc = NPCManager:CreateNPC("Civilian", "Tyler", workspace:WaitForChild("Start").CFrame)

npc:MoveTo(workspace:WaitForChild("Goal"))

local NPCTest = {}

return NPCTest
