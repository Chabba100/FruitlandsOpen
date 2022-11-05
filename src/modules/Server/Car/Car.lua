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

local cooldown = 0
local seat
local occupiedPlayer
local occupiedClientScript
local carClientScript = game:GetService("ServerStorage").CarClient
local DEFAULT_COLLISION_GROUP = "Default"
local CHARACTER_COLLISION_GROUP = "Character"

function Car.new(obj, serviceBag)
	local self = setmetatable(BaseObject.new(obj), Car)

	self._serviceBag = assert(serviceBag, "No serviceBag")
	
    seat = self._obj.Body.VehicleSeat
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

local function Cooldown(duration)
    local cooldownTag = tick()
    cooldown = cooldownTag
    task.delay(duration, function()
        if cooldown == cooldownTag then
            cooldown = 0
        end
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
	self._prompt.Parent = seat.Attachment
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
        if seat.Occupant or cooldown ~= 0 then return end

        local character = player.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        seat:Sit(humanoid)
        occupiedPlayer = player

        SetCharacterCollide(character, false)
        self._obj.PrimaryPart:SetNetworkOwner(player)
        self._prompt.Enabled = false

        occupiedClientScript = carClientScript:Clone()
        occupiedClientScript.Car.Value = self._obj
        occupiedClientScript.Parent = player.Backpack
        Cooldown(1)
    end))
    -- Player leaves
    self._maid:GiveTask(observeProperty(seat, "Occupant"):Subscribe(function()
        if seat.Occupant then return end
        if occupiedPlayer.Character then
            SetCharacterCollide(occupiedPlayer.Character, true)
            self._prompt.Enabled = true
        end
        if occupiedClientScript.Parent  then
            occupiedClientScript.Stop.Value = true
            local client = occupiedClientScript
            task.delay(3, function()
                client:Destroy()
            end)
        end
        self._obj.PrimaryPart:SetNetworkOwnershipAuto()
        occupiedPlayer = nil
        occupiedClientScript = nil
        Cooldown(3)
    end))
end

return Car