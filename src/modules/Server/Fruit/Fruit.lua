local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local GameSettings = require("GameSettings")
local Maid = require("Maid")
local FruitUtil = require("FruitUtil")

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
	self._grabFunction.Parent = self._obj
	self._maid:GiveTask(self._grabFunction)

	self._throwFunction = Instance.new("RemoteFunction")
	self._throwFunction.Name = "ThrowFunction"
	self._throwFunction.Parent = self._obj
	self._maid:GiveTask(self._throwFunction)

	self._maid:GiveTask(self._grabFunction.OnServerEvent:Connect(function(player: Player)
		self._grabMaid:GiveTask(
			FruitUtil.pickup(player, self._obj, self._leftGripAttachmentBinder, self._rightGripAttachmentBinder)
		)
	end))

	self._throwFunction.OnServerInvoke = function(player: Player, hit: Vector3)
		if player:DistanceFromCharacter(hit) >= GameSettings.THROW_DISTANCE then
			return
		end
		--self._isHolding.Value = false
		self._obj:SetAttribute("isHolding", false)
		player:SetAttribute("isHolding", false)

		local hrp = player.Character.HumanoidRootPart
		local g = Vector3.new(0, -workspace.Gravity, 0)
		local x0 = hrp.CFrame * Vector3.new(0, 2, -2)
		local v0 = (hit - x0 - 0.5 * g * GameSettings.THROW_TIME * GameSettings.THROW_TIME) / GameSettings.THROW_TIME

		self._grabMaid:DoCleaning()
		self._obj.Parent = workspace
		self._obj.Position = x0
		self._obj:SetNetworkOwner(player)
		self._obj.Velocity = v0

		-- uncomment if we have exploit issues
		--[[ task.delay(GameSettings.THROW_TIME, function()
            self._obj:SetNetworkOwner(nil)
        end) ]]

		return true
	end

	return self
end

return Fruit
