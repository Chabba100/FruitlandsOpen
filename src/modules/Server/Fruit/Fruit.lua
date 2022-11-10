local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local IKGripUtils = require("IKGripUtils")
local GameSettings = require("GameSettings")
local Maid = require("Maid")
local AttributeValue = require("AttributeValue")

local Fruit = setmetatable({}, BaseObject)
Fruit.ClassName = "Fruit"
Fruit.__index = Fruit

function Fruit.new(obj, serviceBag)
    local self = setmetatable(BaseObject.new(obj), Fruit)

    self._serviceBag = assert(serviceBag, "No serviceBag")
    self._leftGripAttachmentBinder = self._serviceBag:GetService(require("IKBindersServer")).IKLeftGrip
    self._rightGripAttachmentBinder = self._serviceBag:GetService(require("IKBindersServer")).IKRightGrip
    self._grabMaid = Maid.new()

    -- Events
    self._grabFunction = Instance.new("RemoteEvent")
    self._grabFunction.Name = "GrabEvent"
    self._grabFunction.Archivable = false
    self._grabFunction.Parent = self._obj
    self._maid:GiveTask(self._grabFunction)
    self._throwFunction = Instance.new("RemoteFunction")
    self._throwFunction.Name = "ThrowFunction"
    self._throwFunction.Archivable = false
    self._throwFunction.Parent = self._obj
    self._maid:GiveTask(self._throwFunction)

    -- Attributes
    self._isHolding = AttributeValue.new(self._obj, "isHolding", false)
    self._player = AttributeValue.new(self._obj, "player", "nobody")
    self._alreadyPickedUp = AttributeValue.new(self._obj, "alreadyPickedUp", false)

    self._maid:GiveTask(self._grabFunction.OnServerEvent:Connect(function(player: Player)
        if self._obj:FindFirstChild("CarWeld") then
            self._obj.CarWeld:Destroy()
        end
        self._isHolding.Value = true
        if not self._alreadyPickedUp.Value then
            self._alreadyPickedUp.Value = true
            self._player.Value = player.Name
        end
        self._obj.CFrame = player.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0, 0, -1.2))
        self._obj.Parent = player.Character

        -- Create dependencies
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = self._obj
        weld.Part1 = player.Character.HumanoidRootPart
        weld.Parent = self._obj
        self._grabMaid:GiveTask(weld)
        local att = Instance.new("Attachment")
        att.Parent = self._obj
        self._grabMaid:GiveTask(att)

        -- Grip
        local rightObj = IKGripUtils.create(self._leftGripAttachmentBinder, player.Character.Humanoid)
        local leftObj = IKGripUtils.create(self._rightGripAttachmentBinder, player.Character.Humanoid)
        rightObj.Parent = att
        leftObj.Parent = att
        self._grabMaid:GiveTask(rightObj)
        self._grabMaid:GiveTask(leftObj)
    end))

    self._throwFunction.OnServerInvoke = function(player: Player, hit: Vector3)
        self._isHolding.Value = false

        local hrp = player.Character.HumanoidRootPart
        local g = Vector3.new(0, -workspace.Gravity, 0)
        local x0 = hrp.CFrame * Vector3.new(0, 2, -2)
        local v0 = (hit - x0 - 0.5*g*GameSettings.THROW_TIME*GameSettings.THROW_TIME)/GameSettings.THROW_TIME

        self._grabMaid:DoCleaning()
        self._obj.Parent = workspace
        self._obj.Position = x0
        self._obj:SetNetworkOwner(player)
        self._obj.Velocity = v0

        return true
    end

    return self
end

return Fruit