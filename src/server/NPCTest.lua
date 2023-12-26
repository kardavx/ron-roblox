local ServerScriptService = game:GetService("ServerScriptService")

local Civilian = require(ServerScriptService.classes.Civilian)
local NPC = require(ServerScriptService.classes.NPC)
local civilian = Civilian.new()
civilian:Spawn("Tyler", CFrame.new(-10, 0, 30))

local NPCTest = {}

return NPCTest
