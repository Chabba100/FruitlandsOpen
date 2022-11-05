--[=[
	@class BuildButton
]=]

local require = require(script.Parent.loader).load(script)

local BasicPane = require("BasicPane")
local Blend = require("Blend")
local BasicPaneUtils = require("BasicPaneUtils")

local BuildButton = setmetatable({}, BasicPane)
BuildButton.ClassName = "BuildButton"
BuildButton.__index = BuildButton

function BuildButton.new()
	local self = setmetatable(BasicPane.new(), BuildButton)

	self._maid:GiveTask(self:_render():Subscribe(function(gui)
		self.Gui = gui
	end))

	return self
end

function BuildButton:_render()
	local percentVisible = Blend.Spring(BasicPaneUtils.observePercentVisible(self), 30)
	local transparency = BasicPaneUtils.toTransparency(percentVisible)
	local size = Blend.State(UDim2.fromScale(0.1, 0.1))
	local sizeSpring = Blend.Spring(size, 25)

	return Blend.New "ImageButton" {
		Name = "BuildButton";
		Size = sizeSpring;
		AnchorPoint = Vector2.new(0.5, 0.5);
		Position = UDim2.fromScale(0.471, 0.9);
		Active = Blend.Computed(percentVisible, function(visible)
			return visible > 0
		end);
		Visible = Blend.Computed(percentVisible, function(visible)
			return visible > 0
		end);
		BackgroundTransparency = 1;
		ImageTransparency = transparency;
		Image = "rbxassetid://11076318701";

		[Blend.OnEvent "Activated"] = function()
			print("I was clicked!")
		end;

		[Blend.OnEvent "MouseEnter"] = function()
			size.Value = UDim2.fromScale(0.2, 0.2)
		end;

		[Blend.OnEvent "MouseLeave"] = function()
			size.Value = UDim2.fromScale(0.1, 0.1)
		end;

		[Blend.Children] = {
			Blend.New "UIAspectRatioConstraint" {
				AspectRatio = 1;
			}
		}
	}
end

return BuildButton