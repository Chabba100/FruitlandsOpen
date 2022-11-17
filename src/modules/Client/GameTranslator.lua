local require = require(script.Parent.loader).load(script)

return require("JSONTranslator").new("GameTranslator", "en", {
	actions = {
		grab = "Grab";
	}
})