--[=[
	@class GameBindersClient
]=]

local require = require(script.Parent.loader).load(script)

local Binder = require("Binder")
local BinderProvider = require("BinderProvider")

return BinderProvider.new(script.Name, function(self, serviceBag)
	self:Add(Binder.new("Fruit", require("Fruit"), serviceBag))
	self:Add(Binder.new("Combine", require("Combine"), serviceBag))
end)