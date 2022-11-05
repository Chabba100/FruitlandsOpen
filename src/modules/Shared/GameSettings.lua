--[=[
	@class Settings
]=]

local require = require(script.Parent.loader).load(script)

local Table = require("Table")

return Table.readonly({
    THROW_DISTANCE = 30;
    THROW_TIME = 0.5;
})