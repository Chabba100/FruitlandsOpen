local require = require(script.Parent.loader).load(script)

local BasicPane = require("BasicPane")
local Blend = require("Blend")
local Viewport = require("Viewport")
local Rx = require("Rx")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CombineBlob = setmetatable({}, BasicPane)
CombineBlob.ClassName = "CombineBlob"
CombineBlob.__index = CombineBlob

function CombineBlob.new(fruit, numbers)
	local self = setmetatable(BasicPane.new(), CombineBlob)

    self._fruit = fruit
    self._numbers = numbers
    
	self._maid:GiveTask(self:_render():Subscribe(function(gui)
		self.Gui = gui
	end))

	return self
end

function CombineBlob:_render()
    return Blend.New "ImageButton" {
        Name = self._fruit;
        Size = UDim2.fromScale(0.2, 1);
        BackgroundTransparency = 1;
        Image = "rbxassetid://11471105336";

        [Blend.OnEvent "Activated"] = function()
            print(self._fruit, "was clicked!")
        end;

        [Blend.Children] = {
            Viewport.blend({
                Instance = ReplicatedStorage.Fruits[self._fruit]:Clone()
            });
            Blend.New "TextLabel" {
                Name = "Count";
                FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json");
                Text = self._numbers:ObserveValueForKey(self._fruit):Pipe({
                    Rx.map(function(count)
                        return tostring(count)
                    end)
                });
                TextColor3 = Color3.fromRGB(96, 58, 58);
                TextScaled = true;
                TextSize = 14;
                TextWrapped = true;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1;
                Position = UDim2.fromScale(0.75, 0);
                Size = UDim2.fromScale(0.4, 0.4);
            }
        }
    }
end

return CombineBlob