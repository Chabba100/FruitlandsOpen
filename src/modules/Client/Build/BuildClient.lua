--[=[
	@class PlacementClient
]=]

local require = require(script.Parent.loader).load(script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Maid = require("Maid")
local placementClass = require("Placement")
local Spring = require("Spring")
local QFrame = require("QFrame")
local Definitions = require("Definitions")

local PlacementClient = {}
PlacementClient.ServiceName = "PlacementClient"

function PlacementClient:Init(serviceBag)
	self._serviceBag = assert(serviceBag, "No serviceBag")

	self._maid = Maid.new()
	--[[ task.spawn(function()
		self:doStart(ReplicatedStorage.Furniture.Planter)
	end) ]]
end

function PlacementClient:doStart(object)
	local canvas = game.Workspace.Plot
	local furniture = ReplicatedStorage.Furniture

	local dspr
	Definitions.Client:Get("dsPlacement"):CallServerAsync(false, false):andThen(function(result)
		dspr = result
	end):await()
	local placement = placementClass.fromSerialization(canvas, dspr)
	placement.GridUnit = 15

	local mouse = game.Players.LocalPlayer:GetMouse()
	mouse.TargetFilter = placement.CanvasObjects

	local rotation = 0

	local model = object:Clone()
	for index, part in model:GetDescendants() do
		if part:IsA("BasePart") and part.Name ~= "GridPart" then
			part.Transparency = 0.5
		end
	end
	model.Parent = placement.CanvasObjects

	local function onRotate(actionName, userInputState, input)
		if (userInputState == Enum.UserInputState.Begin) then
			rotation = rotation + math.pi/2
		end
	end

	local function onPlace(actionName, userInputState, input)
		if (userInputState == Enum.UserInputState.Begin) then
			local cf = placement:CalcPlacementCFrame(model, mouse.Hit.p, rotation)
			placement:Place(furniture[model.Name], cf, placement:isColliding(model))
		end
	end

	local function onClear(actionName, userInputState, input)
		if (userInputState == Enum.UserInputState.Begin) then
			model.Parent = nil
			placement:Clear()
			model.Parent = mouse.TargetFilter
		end
	end

	local function onSave(actionName, userInputState, input)
		if (userInputState == Enum.UserInputState.Begin) then
			placement:Save()
		end
	end

	--game:GetService("ContextActionService"):BindAction("switch", onSwitch, false, Enum.KeyCode.E)
	game:GetService("ContextActionService"):BindAction("rotate", onRotate, false, Enum.KeyCode.R)
	game:GetService("ContextActionService"):BindAction("place", onPlace, false, Enum.UserInputType.MouseButton1)
	game:GetService("ContextActionService"):BindAction("clear", onClear, false, Enum.KeyCode.C)
	game:GetService("ContextActionService"):BindAction("save", onSave, false, Enum.KeyCode.F)

	-- tweening
	local spring = Spring.new(QFrame.fromCFrameClosestTo(placement:CalcPlacementCFrame(model, mouse.Hit.p, rotation), QFrame.new()))
	spring.d = 1
	spring.s = 30
	local texturespring = Spring.new(1)
	texturespring.d = 1
	texturespring.s = 25
	texturespring.t = 0

	self._maid:GiveTask(game:GetService("RunService").RenderStepped:Connect(function(dt)
		spring.t = QFrame.fromCFrameClosestTo(placement:CalcPlacementCFrame(model, mouse.Hit.p, rotation), spring.p)
		model:PivotTo(QFrame.toCFrame(spring.p))
		canvas.Texture.Transparency = texturespring.p
	end))

	return self._maid
end

return PlacementClient
