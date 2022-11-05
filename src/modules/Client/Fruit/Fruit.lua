local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local GameSettings = require("GameSettings")
local Mouse = require("MouseModule")
local Maid = require("Maid")
local promiseChild = require("promiseChild")
local CameraStackService = require("CameraStackService")

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Fruit = setmetatable({}, BaseObject)
Fruit.ClassName = "Fruit"
Fruit.__index = Fruit

function Fruit.new(obj, serviceBag)
    local self = setmetatable(BaseObject.new(obj), Fruit)

    self._serviceBag = assert(serviceBag, "No serviceBag")
    self._cameraStackService = self._serviceBag:GetService(CameraStackService)

    self._prompt = Instance.new("ProximityPrompt")
    self._prompt.AutoLocalize = false
    self._prompt.Name = "Grab"
    self._prompt.ActionText = "Grab"
    self._prompt.Parent = self._obj
    self._maid:GiveTask(self._prompt)
    self._mouse = Mouse.new()
    self._maid:GiveTask(self._mouse)

    promiseChild(self._obj, "GrabEvent"):Then(function(remoteEvent)
        self._maid:GiveTask(self._prompt.Triggered:Connect(function()
            self._cameraStackService:GetImpulseCamera():Impulse(Vector3.new(1, 0, 1*(math.random()-0.5)))
            self._prompt.Enabled = false
            remoteEvent:FireServer()
            self:_beamThrow()
        end))
    end)

    return self
end

function Fruit:_beamProjectile(g, v0, x0, t1)
	-- calculate the bezier points
	local c = 0.5*0.5*0.5;
	local p3 = 0.5*g*t1*t1 + v0*t1 + x0;
	local p2 = p3 - (g*t1*t1 + v0*t1)/3;
	local p1 = (c*g*t1*t1 + 0.5*v0*t1 + x0 - c*(x0+p3))/(3*c) - p2;
	
	-- the curve sizes
	local curve0 = (p1 - x0).magnitude;
	local curve1 = (p2 - p3).magnitude;
	
	-- build the world CFrames for the attachments
	local b = (x0 - p3).unit;
	local r1 = (p1 - x0).unit;
	local u1 = r1:Cross(b).unit;
	local r2 = (p2 - p3).unit;
	local u2 = r2:Cross(b).unit;
	b = u1:Cross(r1).unit;
	
	local cf1 = CFrame.new(
		x0.x, x0.y, x0.z,
		r1.x, u1.x, b.x,
		r1.y, u1.y, b.y,
		r1.z, u1.z, b.z
	)
	
	local cf2 = CFrame.new(
		p3.x, p3.y, p3.z,
		r2.x, u2.x, b.x,
		r2.y, u2.y, b.y,
		r2.z, u2.z, b.z
	)
	
	return curve0, -curve1, cf1, cf2;
end

function Fruit:_beamThrow()
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = CollectionService:GetTagged("Ignore")

    local g = Vector3.new(0, -workspace.Gravity, 0)
    local hrp = Players.LocalPlayer.Character.HumanoidRootPart
    local throwMaid = Maid.new()

    local attach0 = Instance.new("Attachment", game.Workspace.Terrain)
    local attach1 = Instance.new("Attachment", game.Workspace.Terrain)
    throwMaid:GiveTask(attach0)
    throwMaid:GiveTask(attach1)

    local beam = Instance.new("Beam", game.Workspace.Terrain)
    throwMaid:GiveTask(beam)
    beam.Attachment0 = attach0
    beam.Attachment1 = attach1

    throwMaid:GiveTask(RunService.RenderStepped:Connect(function()
        local x0 = hrp.CFrame * Vector3.new(0, 2, -2)
        local v0 = (self._mouse:Raycast(params).Position - x0 - 0.5*g*GameSettings.THROW_TIME*GameSettings.THROW_TIME)/GameSettings.THROW_TIME

        local curve0, curve1, cf1, cf2 = self:_beamProjectile(g, v0, x0, GameSettings.THROW_TIME)
        beam.CurveSize0 = curve0
        beam.CurveSize1 = curve1
        -- convert world space CFrames to be relative to the attachment parent
        attach0.CFrame = attach0.Parent.CFrame:inverse() * cf1
        attach1.CFrame = attach1.Parent.CFrame:inverse() * cf2
    end))

    -- Throwing
    promiseChild(self._obj, "ThrowFunction"):Then(function(remoteFunction)
        throwMaid:GiveTask(self._mouse.LeftDown:Connect(function()
            self._cameraStackService:GetImpulseCamera():Impulse(Vector3.new(1, 0, 1*(math.random()-0.5)))
            throwMaid:DoCleaning()
            task.delay(GameSettings.THROW_TIME, function()
                self._prompt.Enabled = true
            end)
            remoteFunction:InvokeServer(self._mouse:Raycast(params).Position)
        end))
    end)
end

return Fruit