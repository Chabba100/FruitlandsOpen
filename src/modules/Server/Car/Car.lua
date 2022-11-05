--[=[
	@class Car
]=]

local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local Maid = require("Maid")
local FruitZone = require("FruitZone")
local Observable = require("Observable")
local NumberSpinner = require("NumberSpinner")
local ValueObject = require("ValueObject")
local Fruits = require("Fruits")
local AttributeUtils = require("AttributeUtils")

local PhysicsService = game:GetService("PhysicsService")

local Car = setmetatable({}, BaseObject)
Car.ClassName = "Car"
Car.__index = Car

local carClientScript = game:GetService("ServerStorage").CarClient
local DEFAULT_COLLISION_GROUP = "Default"
local CHARACTER_COLLISION_GROUP = "Character"

function Car.new(obj, serviceBag)
	local self = setmetatable(BaseObject.new(obj), Car)

	self._serviceBag = assert(serviceBag, "No serviceBag")
	
    self._seat = self._obj.Body.VehicleSeat
    self._cooldown = 0
    self._occupiedPlayer = nil
    self._occupiedClientScript = nil

	self:_setup()

	return self
end

local function observeProperty(instance, propertyName)
	return Observable.new(function(sub)
		local maid = Maid.new()

		maid:GiveTask(instance:GetPropertyChangedSignal(propertyName):Connect(function()
			sub:Fire(instance[propertyName], instance)
		end))

		return maid
	end)
end

local function SetCharacterCollide(character, shouldCollide)
    local group = (shouldCollide and DEFAULT_COLLISION_GROUP or CHARACTER_COLLISION_GROUP)
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Massless = not shouldCollide
            PhysicsService:SetPartCollisionGroup(part, group)
        end
    end
end

function Car:_setupThings()
    self._prompt = Instance.new("ProximityPrompt")
    self._prompt.Name = "CarEnter"
	self._prompt.AutoLocalize = false
	self._prompt.ActionText = "Enter!"
	self._prompt.Parent = self._seat.Attachment
	self._maid:GiveTask(self._prompt)

    self._zone = FruitZone.new(self._obj.Body.Zone)
    self._maid:GiveTask(self._zone)

    self._carWeight = ValueObject.new(0)
    self._maid:GiveTask(self._carWeight)

    self._spinner = NumberSpinner.fromGuiObject(self._obj.Body.Zone.g.t)
    self._spinner.Decimals = 0
    self._spinner.Prefix = ""
    self._spinner.Suffix = "/" .. "60"
    
    -- Dynamically change weight
    self._maid:GiveTask(self._carWeight:Observe():Subscribe(function(weight)
        --print("Weight changed,", weight)
        self._spinner.Value = weight
    end))
end

local function cooldown(car, duration)
    local cooldownTag = tick()
    car._cooldown = cooldownTag
    task.delay(duration, function()
        if car._cooldown == cooldownTag then
            car._cooldown = 0
        end
    end)
end

function Car:_setup()
	self:_setupThings()

    -- Observe fruits
    self._maid:GiveTask(self._zone.fruitEntered:Connect(function(fruit)
        self._carWeight.Value += Fruits[fruit.Name].Weight
            task.delay(1, function()
                for _, newF in pairs(self._zone:_getFruits()) do
                    if newF == fruit then
                        if not AttributeUtils.getAttribute(fruit, "isHolding") then
                            local weld = Instance.new("WeldConstraint")
                            weld.Name = "CarWeld"
                            weld.Part0 = fruit
                            weld.Part1 = self._obj.Body.Zone
                            weld.Parent = fruit 
                        end
                    end
                end
            end)
    end))
    self._maid:GiveTask(self._zone.fruitExited:Connect(function(fruit)
        self._carWeight.Value -= Fruits[fruit.Name].Weight
    end))

    -- Player enters
    self._maid:GiveTask(self._prompt.Triggered:Connect(function(player)
        if self._seat.Occupant or self._cooldown ~= 0 then return end

        local character = player.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        self._seat:Sit(humanoid)
        self._occupiedPlayer = player

        SetCharacterCollide(character, false)
        self._obj.PrimaryPart:SetNetworkOwner(player)
        self._prompt.Enabled = false

        self._occupiedClientScript = carClientScript:Clone()
        self._occupiedClientScript.Car.Value = self._obj
        self._occupiedClientScript.Parent = player.Backpack
        cooldown(self, 1)
    end))
    -- Player leaves
    self._maid:GiveTask(observeProperty(self._seat, "Occupant"):Subscribe(function()
        if self._seat.Occupant then return end
        if self._occupiedPlayer.Character then
            SetCharacterCollide(self._occupiedPlayer.Character, true)
            self._prompt.Enabled = true
        end
        if self._occupiedClientScript.Parent  then
            self._occupiedClientScript.Stop.Value = true
            local client = self._occupiedClientScript
            task.delay(3, function()
                client:Destroy()
            end)
        end
        self._obj.PrimaryPart:SetNetworkOwnershipAuto()
        self._occupiedPlayer = nil
        self._occupiedClientScript = nil
        cooldown(self, 3)
    end))
end

return Car