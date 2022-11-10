local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local promiseChild = require("promiseChild")
local CombineBlob = require("CombineBlob")
local Blend = require("Blend")
local ObservableList = require("ObservableList")
local Rx = require("Rx")
local ObservableMap = require("ObservableMap")

local Players = game:GetService("Players")

local Combine = setmetatable({}, BaseObject)
Combine.ClassName = "Combine"
Combine.__index = Combine

function Combine.new(obj, serviceBag)
    local self = setmetatable(BaseObject.new(obj), Combine)

    self._fruits = ObservableList.new()
    self._numbers = ObservableMap.new()
    self._blobs = ObservableMap.new()
    self._maid:GiveTask(self._fruits)
    self._maid:GiveTask(self._numbers)
    self._maid:GiveTask(self._blobs)

    self._maid:GiveTask(self._numbers.KeyValueChanged:Connect(function(key, value)
        if value == 0 then
            self._blobs:Get(key):Destroy()
            self._blobs:Set(key, nil)
        end
    end))

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
                        Rx.map(function(brio)
                            if brio:IsDead() then
                                return
                            end

                            local fruit = brio:GetValue()
                            local brioMaid = brio:ToMaid()

                            self:_count(fruit)

                            brioMaid:GiveTask(function()
                                self:_count(fruit)
                            end)

                            if not self._blobs:Get(fruit) then
                                local blob = CombineBlob.new(fruit, self._numbers)
                                self._blobs:Set(fruit, blob)

                                return blob.Gui
                            end

                            return Rx.EMPTY
                        end)
                    })
                }
            }
        }
    }):Subscribe(function(gui)
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

function Combine:_count(fruit)
    local count = 0
    for _, v in pairs(self._fruits:GetList()) do
        if v == fruit then
            count += 1
        end
    end
    self._numbers:Set(fruit, count)
end

return Combine