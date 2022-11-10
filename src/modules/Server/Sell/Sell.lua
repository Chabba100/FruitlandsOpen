local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local FruitZone = require("FruitZone")
local Fruits = require("Fruits")
local AttributeUtils = require("AttributeUtils")

local Sell = setmetatable({}, BaseObject)
Sell.ClassName = "Sell"
Sell.__index = Sell

function Sell.new(obj, serviceBag)
    local self = setmetatable(BaseObject.new(obj), Sell)

    self._serviceBag = assert(serviceBag, "No serviceBag")
    
    self._zone = FruitZone.new(self._obj)
    self._maid:GiveTask(self._zone)

    self._maid:GiveTask(self._zone.fruitEntered:Connect(function(fruit)
        if AttributeUtils.getAttribute(fruit, "isHolding", false) then
            print("holding")
            return
        end
        local player = game.Players[AttributeUtils.getAttribute(fruit, "player", "nobody")]
        local price = Fruits[fruit.Name].SellPrice

        player.Gold.Value += price
        fruit:Destroy()
    end))

    return self
end

return Sell