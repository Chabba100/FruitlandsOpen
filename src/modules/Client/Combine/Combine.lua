local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local promiseChild = require("promiseChild")
local CombineBlob = require("CombineBlob")
local ObservableList = require("ObservableList")

local Players = game:GetService("Players")

local Combine = setmetatable({}, BaseObject)
Combine.ClassName = "Combine"
Combine.__index = Combine

function Combine.new(obj, serviceBag)
    local self = setmetatable(BaseObject.new(obj), Combine)

    self._fruits = ObservableList.new()
    self._maid:GiveTask(self._fruits)

    -- Construct billboard
    self._blob = CombineBlob.new(self._fruits, self._obj.CombineLoc)
    self._maid:GiveTask(self._blob)

    self._blob:Show()
    self._blob.Gui.Parent = Players.LocalPlayer.PlayerGui

    promiseChild(self._obj, "FruitAdded"):Then(function(event)
        self._maid:GiveTask(event.OnClientEvent:Connect(function(fruitName)
            self._fruits:Add(fruitName)
            print(self._fruits:GetList())
        end))
    end)
    promiseChild(self._obj, "FruitLeft"):Then(function(event)
        self._maid:GiveTask(event.OnClientEvent:Connect(function(fruitName)
            self._fruits:RemoveFirst(fruitName)
            print(self._fruits:GetList())
        end))
    end)

    return self
end

return Combine