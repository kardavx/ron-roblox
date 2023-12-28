local NPCSConfig = {}

return setmetatable(NPCSConfig, {
	__index = function()
		return {
			animationsInfo = {
				Idle = {
					{ Id = 15746292677 },
				},
				Run = {
					{ Id = 15770191690 },
				},
				Walk = {
					{ Id = 15770191690 },
				},
				HandsUp = {
					{ Id = 15771932574 },
				},
				OnKnees = {
					{ Id = 15782182058 },
				},
			},
		}
	end,
})
