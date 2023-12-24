return {
	tagName = "Interaction",
	--- Zwraca instancje do janitora
	onInstanceAdded = function(instance: Instance): () -> ()
		return function() end
	end,
}
