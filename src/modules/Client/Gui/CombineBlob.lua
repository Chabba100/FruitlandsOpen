local require = require(script.Parent.loader).load(script)

local BasicPane = require("BasicPane")
local Blend = require("Blend")
local BasicPaneUtils = require("BasicPaneUtils")
local RxBrioUtils = require("RxBrioUtils")

local CombineBlob = setmetatable({}, BasicPane)
CombineBlob.ClassName = "CombineBlob"
CombineBlob.__index = CombineBlob

function CombineBlob.new(fruitList, adornee)
	local self = setmetatable(BasicPane.new(), CombineBlob)

    self._adornee = adornee
    self._fruitList = fruitList

	self._maid:GiveTask(self:_render():Subscribe(function(gui)
		self.Gui = gui
	end))

	return self
end

function CombineBlob:_render()
    local percentVisible = Blend.Spring(BasicPaneUtils.observePercentVisible(self), 30)
    local transparency = BasicPaneUtils.toTransparency(percentVisible)

    return Blend.New "BillboardGui" {
        Name = "CombineBasket";
        Adornee = self._adornee;
        Size = UDim2.fromScale(4, 1);

        [Blend.Children] = {
            Blend.New "Frame" {
                Size = UDim2.fromScale(1, 1);

                [Blend.Children] = {
                    self._fruitList:ObserveItemsBrio():Pipe({
                        RxBrioUtils.map(function(fruitName)
                            print(fruitName)
                            return Blend.New "ImageButton" {
                                Name = fruitName;
                                Size = UDim2.fromScale(0.2, 1);
                                BackgroundColor3 = Color3.fromRGB(182, 21, 21);

                                [Blend.Children] = {
                                    Blend.New "UIAspectRatioConstraint" {
                                        AspectRatio = 1;
                                    }
                                }
                            }
                        end)
                    }),
                    Blend.New "UIListLayout" {
                        FillDirection = Enum.FillDirection.Horizontal;
                        --Padding = UDim.new(0, 5)
                    }
                }
            }
        }
    }

end

return CombineBlob