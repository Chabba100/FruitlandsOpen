--[=[
	@class GameBindersServer
]=]

local require = require(script.Parent.loader).load(script)

local Binder = require("Binder")
local BinderProvider = require("BinderProvider")
local PlayerHumanoidBinder = require("PlayerHumanoidBinder")

return BinderProvider.new(function(self, serviceBag)
	self:Add(Binder.new("Fruit", require("Fruit"), serviceBag))
	self:Add(Binder.new("Car", require("Car"), serviceBag))
	self:Add(Binder.new("Combine", require("Combine"), serviceBag))
end)