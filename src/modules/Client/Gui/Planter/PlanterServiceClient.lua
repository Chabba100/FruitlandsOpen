--[=[
	@class PlanterServiceClient
]=]

local require = require(script.Parent.loader).load(script)

local Planter = require("Planter")
local PlayerGuiUtils = require("PlayerGuiUtils")
local Router = require("Router")

local PlanterServiceClient = {}

function PlanterServiceClient:Init(serviceBag)
	self._serviceBag = assert(serviceBag, "No serviceBag")

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "Planters"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.AutoLocalize = false
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.DisplayOrder = 1e9
	ScreenGui.Parent = PlayerGuiUtils.getPlayerGui()
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	self._planterUI = Planter.new()

	self._planterUI.Gui.Parent = ScreenGui

	Router.Route.Changed:Connect(function(oldvalue, newvalue)
		if self._planterUI:IsVisible() == false and newvalue == "Planter" then
			self._planterUI:Show()
		else
			self._planterUI:Hide()
		end
		--[[if Router.Route.Value == "Planter" then
			self._planterUI:Show()
		else
			self._planterUI:Hide()
		end--]]
	end)
end

return PlanterServiceClient
