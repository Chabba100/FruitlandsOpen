--[[
	@class BuildButton.story
]]

local require = require(game:GetService("ServerScriptService"):FindFirstChild("LoaderUtils", true).Parent).load(script)

local Maid = require("Maid")
local BuildButton = require("BuildButton")
local ServiceBag = require("ServiceBag")

return function(target)
	local maid = Maid.new()
	local serviceBag = ServiceBag.new()
	maid:GiveTask(serviceBag)

	local BuildButton = BuildButton.new()
	maid:GiveTask(BuildButton)

	BuildButton:Show()

	BuildButton.Gui.Parent = target

	return function()
		maid:DoCleaning()
	end
end