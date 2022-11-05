local require = require(script.Parent.loader).load(script)

return require("JSONTranslator").new("GameTranslator", "en", {
	actions = {
		ragdoll = "Go down",
		unragdoll = "Go up",
	}
})