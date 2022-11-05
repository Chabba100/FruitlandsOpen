--[=[
	@class Planter
]=]

local require = require(script.Parent.loader).load(script)

local BasicPane = require("BasicPane")
local Blend = require("Blend")
local BasicPaneUtils = require("BasicPaneUtils")

local Planter = setmetatable({}, BasicPane)
Planter.ClassName = "Planter"
Planter.__index = Planter

function Planter.new()
	local self = setmetatable(BasicPane.new(), Planter)

	self._maid:GiveTask(self:_render():Subscribe(function(gui)
		self.Gui = gui
	end))

	return self
end

function Planter:_render()
	local percentVisible = Blend.Spring(BasicPaneUtils.observePercentVisible(self), 30)
	local transparency = BasicPaneUtils.toTransparency(percentVisible)
	
	return Blend.New "ImageLabel" {
		Name = "Planters";
		Size = UDim2.fromOffset(300, 200);
		AnchorPoint = Vector2.new(0.5, 0.5);
		Position = UDim2.fromScale(0.5, 0.5);
		BackgroundTransparency = transparency;

		[Blend.Children] = {
			Blend.New "UIScale" {
				Scale = Blend.Computed(percentVisible, function(percent)
					return 0.8 + 0.2 * percent
				end)
			}
		}
	}
end

return Planter