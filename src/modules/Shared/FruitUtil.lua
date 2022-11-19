local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local IKGripUtils = require("IKGripUtils")

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local FruitUtil = {}

function FruitUtil.canPickup(character: Model)
	for _, part in pairs(character:GetDescendants()) do
		if CollectionService:HasTag(part, "Fruit") then
			return false
		end
	end
	return true
end

function FruitUtil.pickup(player, object, left, right, combined, calculatedPrice, calculatedWeight)
	-- Checks
	if RunService:IsClient() then
		return
	end
	if not FruitUtil.canPickup(player.Character) then
		return
	end
	if object:FindFirstChild("CarWeld") then
		object.CarWeld:Destroy()
	end

	local grabMaid = Maid.new()
	print("from fruitUtil!!!")

	object:SetAttribute("isHolding", true)
	if not object:GetAttribute("alreadyPickedUp") then
		object:SetAttribute("alreadyPickedUp", true)
		object:SetAttribute("player", player.Name)
	end

	object.CFrame = player.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0, 0, -1.2))
	object.Parent = player.Character

	-- Create dependencies
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = object
	weld.Part1 = player.Character.HumanoidRootPart
	weld.Parent = object
	local att = Instance.new("Attachment")
	att.Parent = object
	grabMaid:GiveTask(weld)
	grabMaid:GiveTask(att)

	-- Grip
	local rightObj = IKGripUtils.create(left, player.Character.Humanoid)
	local leftObj = IKGripUtils.create(right, player.Character.Humanoid)
	rightObj.Parent = att
	leftObj.Parent = att
	grabMaid:GiveTask(rightObj)
	grabMaid:GiveTask(leftObj)

	return grabMaid
end

return FruitUtil
