local require = require(script.Parent.loader).load(script)

local BasicPane = require("BasicPane")
local Blend = require("Blend")
local BasicPaneUtils = require("BasicPaneUtils")

local CombineBlob = setmetatable({}, BasicPane)
CombineBlob.ClassName = "CombineBlob"
CombineBlob.__index = CombineBlob

function CombineBlob.new(fruits)
	local self = setmetatable(BasicPane.new(), CombineBlob)

    self._adornee = Blend.State()
    self._fruits = fruits

    print(self._fruits)

	self._maid:GiveTask(self:_render():Subscribe(function(gui)
		self.Gui = gui
	end))

	return self
end

function CombineBlob:SetAdornee(what)
    self._adornee.Value = what
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
                    Blend.New "UIListLayout" {
                        FillDirection = Enum.FillDirection.Horizontal;
                    };
                    Blend.ComputedPairs(self._fruits, function(_index, value, innerMaid)
                        print("running")
                        return Instance.new("Frame")
                    end)
                }
            }
        }
    }

end

return CombineBlob