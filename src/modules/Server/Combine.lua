local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local FruitZone = require("FruitZone")
local AttributeUtils = require("AttributeUtils")

local Combine = setmetatable({}, BaseObject)
Combine.ClassName = "Combine"
Combine.__index = Combine

function Combine.new(obj, serviceBag)
    local self = setmetatable(BaseObject.new(obj), Combine)

    self._zone = FruitZone.new(self._obj.Zone)
    self._maid:GiveTask(self._zone)

    self._fruitAdded = Instance.new("RemoteEvent")
    self._fruitAdded.Name = "FruitAdded"
    self._fruitAdded.Parent = self._obj

    self._fruitLeft = Instance.new("RemoteEvent")
    self._fruitLeft.Name = "FruitLeft"
    self._fruitLeft.Parent = self._obj

    self._combine = Instance.new("RemoteEvent")
    self._combine.Name = "Combine"
    self._combine.Parent = self._obj

    self._maid:GiveTask(self._fruitAdded)
    self._maid:GiveTask(self._fruitLeft)
    self._maid:GiveTask(self._combine)

    self._maid:GiveTask(self._zone.fruitEntered:Connect(function(fruit)
        local player = game.Players:FindFirstChild(AttributeUtils.getAttribute(fruit, "player"))
        if not player then return end

        self._fruitAdded:FireClient(player, fruit.Name)
    end))

    self._maid:GiveTask(self._zone.fruitExited:Connect(function(fruit)
        local player = game.Players:FindFirstChild(AttributeUtils.getAttribute(fruit, "player"))
        if not player then return end

        self._fruitLeft:FireClient(player, fruit.Name)
    end))

    return self
end

return Combine