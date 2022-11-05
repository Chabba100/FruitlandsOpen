--[=[
	@class Fruits
]=]

local require = require(script.Parent.loader).load(script)

local Table = require("Table")

return Table.readonly({
    Apple = {
        Weight = 5;
        SellPrice = 10;
    };
    Watermelon = {
        Weight = 10;
        SellPrice = 10;
    }
})