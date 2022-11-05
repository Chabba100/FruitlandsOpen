--[=[
	@class CollisionService
]=]

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")

local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")

local CollisionService = {}

function CollisionService:Init(serviceBag)
	local maid = Maid.new()
	local players = PhysicsService:CreateCollisionGroup("Players", "Players", false)

	maid:GiveTask(Players.PlayerAdded:Connect(function(player)
		maid:GiveTask(player.CharacterAdded:Connect(function(character)
			repeat task.wait(1) until character:WaitForChild("Humanoid")

			for _, characterPart in pairs(character:GetChildren()) do
				if characterPart:IsA("BasePart") then
					PhysicsService:SetPartCollisionGroup(characterPart, "Players")
				end
			end
		end))
	end))
end

return CollisionService
