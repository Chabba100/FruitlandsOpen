local require = require(script.Parent.loader).load(script)

local BasicPane = require("BasicPane")
local Blend = require("Blend")
local Viewport = require("Viewport")
local Rx = require("Rx")
local Signal = require("Signal")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CombineBlob = setmetatable({}, BasicPane)
CombineBlob.ClassName = "CombineBlob"
CombineBlob.__index = CombineBlob

function CombineBlob.new(fruit, fruits)
	local self = setmetatable(BasicPane.new(), CombineBlob)

    self._fruit = fruit
    self._fruits = fruits
    
    self.DestroySignal = Signal.new()
    self._maid:GiveTask(self.DestroySignal)
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
                Text = self._fruits:ObserveCount():Pipe({
                    Rx.map(function()
                        local ofFruit = 0
                        for _, fruit in pairs(self._fruits:GetList()) do
                            print(fruit)
                            if fruit == self._fruit then
                                ofFruit += 1
                            end
                        end
                        if ofFruit > 1 then
                            print("yes")
                            self.DestroySignal:Fire()
                        end
                        return "x" .. tostring(ofFruit)
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