--[[
	@class Planter.story
]]

local require = require(game:GetService("ServerScriptService"):FindFirstChild("LoaderUtils", true).Parent).load(script)

local Maid = require("Maid")
local Planter = require("Planter")
local ServiceBag = require("ServiceBag")

return function(target)
	local maid = Maid.new()
	local serviceBag = ServiceBag.new()
	maid:GiveTask(serviceBag)

	local Planter = Planter.new()
	maid:GiveTask(Planter)

	Planter:Show()

	Planter.Gui.Parent = target

	return function()
		maid:DoCleaning()
	end
end