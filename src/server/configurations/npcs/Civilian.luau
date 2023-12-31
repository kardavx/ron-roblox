local NPCSConfig = {}

return setmetatable(NPCSConfig, {
	__index = function()
		return {
			Durations = {
				RunAway = 10,
			},
			LevelRequirments = {
				HandsUp = {
					Intimidation = { [">="] = 0.5 },
				},
				OnKnees = {
					Intimidation = { [">="] = 0.75 },
				},
				RunAway = {
					Aggressiveness = { [">"] = 0.5 },
					Intimidation = { ["<="] = 0.5 },
				},
			},
			AnimationsInfo = {
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
				Arrest = {
					{ Id = 15786781472 },
				},
			},
		}
	end,
})
