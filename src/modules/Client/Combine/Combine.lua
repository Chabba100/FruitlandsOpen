local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local promiseChild = require("promiseChild")
local CombineBlob = require("CombineBlob")
local Blend = require("Blend")
local ObservableList = require("ObservableList")
local RxBrioUtils = require("RxBrioUtils")
local Rx = require("Rx")

local Players = game:GetService("Players")

local Combine = setmetatable({}, BaseObject)
Combine.ClassName = "Combine"
Combine.__index = Combine

function Combine.new(obj, serviceBag)
    local self = setmetatable(BaseObject.new(obj), Combine)

    self._fruits = ObservableList.new()
    self._numbers = Blend.State({})
    self._maid:GiveTask(self._fruits)
    self._maid:GiveTask(self._numbers)

    self._maid:GiveTask((Blend.New "BillboardGui" {
        Name = "CombineBasket";
        Active = true;
        Size = UDim2.fromScale(5, 1);
        Adornee = self._obj.CombineLoc;

        [Blend.Children] = {
            Blend.New "Frame" {
                Size = UDim2.fromScale(1, 1);
                BackgroundTransparency = 1;

                [Blend.Children] = {
                    Blend.New "UIListLayout" {
                        FillDirection = Enum.FillDirection.Horizontal;
                        VerticalAlignment = Enum.VerticalAlignment.Center;
                        Padding = UDim.new(0, 8)
                    };
                    self._fruits:ObserveItemsBrio():Pipe({
                        RxBrioUtils.map(function(fruit)
                            local blob = CombineBlob.new(fruit, self._fruits)
                            blob.DestroySignal:Connect(function()
                                blob.Gui:Destroy()
                            end)
                            return blob.Gui
                        end)
                    })
                }
            }
        }
    }):Subscribe(function(gui)
        print(gui)
        gui.Parent = Players.LocalPlayer.PlayerGui
    end))

    promiseChild(self._obj, "FruitAdded"):Then(function(event)
        self._maid:GiveTask(event.OnClientEvent:Connect(function(fruitName)
            self._fruits:Add(fruitName)
        end))
    end)
    promiseChild(self._obj, "FruitLeft"):Then(function(event)
        self._maid:GiveTask(event.OnClientEvent:Connect(function(fruitName)
            self._fruits:RemoveFirst(fruitName)
        end))
    end)

    return self
end

return Combine