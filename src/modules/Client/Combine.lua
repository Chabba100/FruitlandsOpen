local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local promiseChild = require("promiseChild")
local Blend = require("Blend")
local CombineBlob = require("CombineBlob")

local Players = game:GetService("Players")

local Combine = setmetatable({}, BaseObject)
Combine.ClassName = "Combine"
Combine.__index = Combine

function Combine.new(obj, serviceBag)
    local self = setmetatable(BaseObject.new(obj), Combine)
    
    self._fruits = Blend.State({})
    self._maid:GiveTask(self._fruits)

    self._fruits.Changed:Connect(function()
        print("changed")
    end)

    -- Construct billboard
    self._blob = CombineBlob.new(self._fruits)
    self._maid:GiveTask(self._blob)
    self._blob:SetAdornee(self._obj.CombineLoc)
    self._blob:Show()
    self._blob.Gui.Parent = Players.LocalPlayer.PlayerGui

    promiseChild(self._obj, "FruitAdded"):Then(function(event)
        self._maid:GiveTask(event.OnClientEvent:Connect(function(fruitName)
            local currentValue = self._fruits.Value
            table.insert(currentValue, fruitName)
            self._fruits.Value = currentValue
            print(self._fruits.Value)
        end))
    end)
    promiseChild(self._obj, "FruitLeft"):Then(function(event)
        self._maid:GiveTask(event.OnClientEvent:Connect(function(fruitName)
            local currentValue = self._fruits.Value
            table.remove(currentValue, table.find(currentValue, fruitName))
            self._fruits.Value = currentValue
            print(self._fruits.Value)
        end))
    end)

    return self
end

return Combine