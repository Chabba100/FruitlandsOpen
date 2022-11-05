--[=[
	@class Placement
]=]

local require = require(script.Parent.loader).load(script)

local Definitions = require("Definitions")

local CollectionService = game:GetService("CollectionService")

local isServer = game:GetService("RunService"):IsServer()
local furniture = game:GetService("ReplicatedStorage").Furniture

local Placement = {}
Placement.__index = Placement

function Placement.new(canvasPart)
	local self = setmetatable({}, Placement)

	self.CanvasPart = canvasPart
	
	if (isServer) then
		self.CanvasObjects = Instance.new("Folder")
		self.CanvasObjects.Name = "CanvasObjects"
		self.CanvasObjects.Parent = canvasPart
	else
		local objs
		Definitions.Client:Get("initPlacement"):CallServerAsync(canvasPart):andThen(function(result)
			objs = result
		end):await()
		self.CanvasObjects = objs
	end
	
	self.Surface = Enum.NormalId.Top
	self.GridUnit = 1

	return self
end

function Placement.fromSerialization(canvasPart, data)
	local self = Placement.new(canvasPart)
	local canvasCF = canvasPart.CFrame
	data = data or {}
	
	for cf, name in pairs(data) do
		local model = furniture:FindFirstChild(name)
		if (model) then
			local components = {}
			for num in string.gmatch(cf, "[^%s,]+") do
				components[#components+1] = tonumber(num)
			end
			
			self:Place(model, canvasCF * CFrame.new(unpack(components)), false)
		end
	end
	
	return self
end

-- methods

function Placement:CalcCanvas()
	local canvasSize = self.CanvasPart.Size

	local up = Vector3.new(0, 1, 0)
	local back = -Vector3.FromNormalId(self.Surface)
	
	local dot = back:Dot(Vector3.new(0, 1, 0))
	local axis = (math.abs(dot) == 1) and Vector3.new(-dot, 0, 0) or up
	
	local right = CFrame.fromAxisAngle(axis, math.pi/2) * back
	local top = back:Cross(right).unit

	local cf = self.CanvasPart.CFrame * CFrame.fromMatrix(-back*canvasSize/2, right, top, back)
	local size = Vector2.new((canvasSize * right).magnitude, (canvasSize * top).magnitude)

	return cf, size
end

function Placement:CalcPlacementCFrame(model, position, rotation)
	local cf, size = self:CalcCanvas()

	local modelSize = CFrame.fromEulerAnglesYXZ(0, rotation, 0) * model.PrimaryPart.Size
	modelSize = Vector3.new(math.abs(modelSize.x), math.abs(modelSize.y), math.abs(modelSize.z))

	local lpos = cf:pointToObjectSpace(position);
	local size2 = (size - Vector2.new(modelSize.x, modelSize.z))/2
	local x = math.clamp(lpos.x, -size2.x, size2.x);
	local y = math.clamp(lpos.y, -size2.y, size2.y);
	
	local g = self.GridUnit
	if (g > 0) then
		x = math.sign(x)*((math.abs(x) - math.abs(x) % g) + (size2.x % g))
		y = math.sign(y)*((math.abs(y) - math.abs(y) % g) + (size2.y % g))
	end
	
	return cf * CFrame.new(x, y, -modelSize.y/2) * CFrame.Angles(-math.pi/2, rotation, 0)
end

function Placement:isColliding(model)
	local isColliding = false

	local touch = model.PrimaryPart.Touched:Connect(function() end)
	local touching = model.PrimaryPart:GetTouchingParts()
	
	for i = 1, #touching do
		if (not touching[i]:IsDescendantOf(model)) then
			isColliding = true
			break
		end
	end

	touch:Disconnect()
	return isColliding
end

function Placement:Place(model, cf, isColliding)
	if (not isColliding and isServer) then
		local clone = model:Clone()
		clone:SetPrimaryPartCFrame(cf)
		clone.Parent = self.CanvasObjects
		if model.Name == "Planter" then
			CollectionService:AddTag(model, "Planter")
		end
	end

	if (not isServer) then
		Definitions.Client:Get("invokePlacement"):SendToServer("Place", model, cf, isColliding)
	end
end

function Placement:Serialize()
	local serial = {}
	
	local cfi = self.CanvasPart.CFrame:inverse()
	local children = self.CanvasObjects:GetChildren()
	
	for i = 1, #children do
		serial[tostring(cfi * children[i].PrimaryPart.CFrame)] = children[i].Name 
	end
	
	return serial
end

function Placement:Save()
	local dsr
	Definitions.Client:Get("dsPlacement"):CallServerAsync(true, true):andThen(function(result)
		dsr = result
	end):await()
	if (dsr) then
		print("Saved")
	end
end

function Placement:Clear()
	self.CanvasObjects:ClearAllChildren()
	
	if (not isServer) then
		Definitions.Client:Get("invokePlacement"):SendToServer("Clear")
		local dsr
		Definitions.Client:Get("dsPlacement"):CallServerAsync(true, false):andThen(function(result)
			dsr = result
		end):await()
		if (dsr) then
			print("Cleared")
		end
	end
end

return Placement
