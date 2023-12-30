local ReplicatedStorage = game:GetService("ReplicatedStorage")

local clientState = require(ReplicatedStorage.Shared.reflex.clientState)
local serverProfile = require(ReplicatedStorage.Shared.reflex.serverProfile)

export type CommonProps = {
	clientState: clientState.Producer,
	serverProfile: serverProfile.Producer?,
}

return table.freeze({})
