--[=[
	@class GameBindersServer
]=]

local require = require(script.Parent.loader).load(script)

local Binder = require("Binder")
local BinderProvider = require("BinderProvider")
local PlayerBinder = require("PlayerBinder")

return BinderProvider.new(script.Name, function(self, serviceBag)
	self:Add(Binder.new("Fruit", require("Fruit"), serviceBag))
	self:Add(Binder.new("Car", require("Car"), serviceBag))
	self:Add(Binder.new("Combine", require("Combine"), serviceBag))
	self:Add(Binder.new("Sell", require("Sell"), serviceBag))
	self:Add(PlayerBinder.new("Gold", require("Gold"), serviceBag))
end)