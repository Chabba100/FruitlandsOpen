--[=[
	@class CarZone
]=]

local require = require(script.Parent.loader).load(script)

local Signal = require("Signal")
local BaseObject = require("BaseObject")

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local CarZone = setmetatable({}, BaseObject)
CarZone.ClassName = "CarZone"
CarZone.__index = CarZone

function CarZone.new(part)
    local self = setmetatable(BaseObject.new(part), CarZone)

    self._fruitsInside = {}
    self._oldFruits = {}
    self._interval = 0.5
    self._nextStep = tick() + self._interval

    self.fruitEntered = Signal.new()
    self.fruitExited = Signal.new()
    self._maid:GiveTask(self.fruitEntered)
    self._maid:GiveTask(self.fruitExited)

    self:_start()

    return self
end

function CarZone:_start()
    self._maid:GiveTask(RunService.Heartbeat:Connect(function(dt)
        if tick() >= self._nextStep then
            self._nextStep += self._interval

            -- Get fruits inside
            self._fruitsInside = self:_getFruits()

            -- Check already entered
            self:_checkNewFruitsInside(self._oldFruits, self._fruitsInside)

            -- Check players left
            self:_checkFruitsLeft(self._oldFruits, self._fruitsInside)

            -- Replace old with new
            self._oldFruits = self._fruitsInside
        end
    end))
end

function CarZone:_getFruits()
    local params = OverlapParams.new()
    local list = {}
    for _, fruit in pairs(workspace:GetPartBoundsInBox(self._obj.CFrame, self._obj.Size, params)) do
        if CollectionService:HasTag(fruit, "Fruit") then
            table.insert(list, fruit)
        end
    end
    return list
end

function CarZone:_checkNewFruitsInside(oldTable, newTable)
	for i, v in pairs(newTable) do
		if not table.find(oldTable, v) then
			--print(v.Name .. " Entered")
            self.fruitEntered:Fire(v)
		end
	end
end

function CarZone:_checkFruitsLeft(oldTable, newTable)
	for i, v in pairs(oldTable) do
		if not table.find(newTable, v) then
			--print(v.Name .. " Exited")
            self.fruitExited:Fire(v)
		end
	end
end

return CarZone
