export type Occlusion = "Enemy" | "Friendly" | "Unknown"
export type DialogData = {
	Occlusion: Occlusion,
	Text: string,
	Name: string?,
}

return table.freeze({})
