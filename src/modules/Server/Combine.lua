local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local FruitZone = require("FruitZone")
local AttributeUtils = require("AttributeUtils")
local ObservableList = require("ObservableList")
local Spring = require("Spring")
local Maid = require("Maid")

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local Combine = setmetatable({}, BaseObject)
Combine.ClassName = "Combine"
Combine.__index = Combine

local function ComputeCircleCoords(StartVector3, amountofitems, Arclength)
	local AngleBetweenInDegrees = 360 / amountofitems
	local AngleBetweenInRad = math.rad(AngleBetweenInDegrees)
	local Radius = Arclength / AngleBetweenInRad + 2
	local tab = {}
	local currentangle = 0
	for num = 1, amountofitems do
		currentangle += AngleBetweenInRad
		local z = math.cos(currentangle) * Radius
		local x = math.sin(currentangle) * Radius
		local vector3 = StartVector3 + Vector3.new(x, 0, z)
		table.insert(tab, vector3)
	end

	return tab
end

function Combine.new(obj, serviceBag)
	local self = setmetatable(BaseObject.new(obj), Combine)

	self._zone = FruitZone.new(self._obj.Zone)
	self._maid:GiveTask(self._zone)

	self._fruits = ObservableList.new()
	self._maid:GiveTask(self._fruits)

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
		if not player then
			return
		end

		self._fruits:Add(fruit)
		self._fruitAdded:FireClient(player, fruit.Name)
	end))

	self._maid:GiveTask(self._zone.fruitExited:Connect(function(fruit)
		local player = game.Players:FindFirstChild(AttributeUtils.getAttribute(fruit, "player"))
		if not player then
			return
		end

		self._fruits:RemoveFirst(fruit)
		self._fruitLeft:FireClient(player, fruit.Name)
	end))

	self._maid:GiveTask(self._combine.OnServerEvent:Connect(function(player, fruit)
		local combineMaid = Maid.new()
		local count = self:_count(fruit)
		local cords = ComputeCircleCoords(self._obj.CombineLoc.Position, count, 2)

		-- Loop to get fruit objects
		local fruits = {}
		for i, v in pairs(self._fruits:GetList()) do
			if v.Name == fruit then
				table.insert(fruits, v)
			end
		end

		-- move fruits
		local moveMaid = Maid.new()
		for i, pos in pairs(cords) do
			local spring = Spring.new(fruits[i].Position)
			spring.s = 9
			spring.t = pos
			fruits[i].Anchored = true
			fruits[i].CanCollide = false
			CollectionService:RemoveTag(fruits[i], "Fruit")

			moveMaid:GiveTask(RunService.Heartbeat:Connect(function()
				fruits[i].Position = spring.p
			end))
			task.wait(0.2)
		end
		task.wait(2)
		moveMaid:DoCleaning()
		moveMaid = nil

		local Model = Instance.new("Model")
		Model.Parent = self._obj
		combineMaid:GiveTask(Model)

		local Center = Instance.new("Part")
		Center.Transparency = 1
		Center.Anchored = true
		Center.CanCollide = false
		Center.Size = Vector3.new(1, 1, 1)
		Center.Position = self._obj.CombineLoc.Position
		Center.Parent = Model
		combineMaid:GiveTask(Center)
		Model.PrimaryPart = Center

		local current = 0.08

		local spin = RunService.Heartbeat:Connect(function()
			current += 0.002
			Model:SetPrimaryPartCFrame(Center.CFrame * CFrame.fromEulerAnglesXYZ(0, current, 0))
		end)
	end))

	return self
end

function Combine:_count(fruit)
	local count = 0
	for _, v in pairs(self._fruits:GetList()) do
		if v.Name == fruit then
			count += 1
		end
	end
	return count
end

return Combine
