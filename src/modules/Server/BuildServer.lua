--[=[
	@class BuildServer
]=]

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local placementClass = require("Placement")
local Definitions = require("Definitions")

local datastore = game:GetService("DataStoreService"):GetDataStore("PlacementSystem")

local BuildServer = {}

function BuildServer:Init(serviceBag)
	self._serviceBag = assert(serviceBag, "No serviceBag")

	self._maid = Maid.new()
	task.spawn(function()
		self:_setup()
	end)
end

function BuildServer:_setup()
	local placementObjects = {}
	local initPlacement = Definitions.Server:Get("initPlacement"):GetInstance()
	local invokePlacement = Definitions.Server:Get("invokePlacement"):GetInstance()
	local dsPlacement = Definitions.Server:Get("dsPlacement"):GetInstance()

	-- creates the server twin, stores in a table and returns the CanvasObjects property
	function initPlacement.OnServerInvoke(player, canvasPart)
		placementObjects[player] = placementClass.new(canvasPart)
		return placementObjects[player].CanvasObjects
	end
	
	-- finds the server twin and calls a method on it
	-- note: b/c we aren't using the standard method syntax we must manually put in the self argument
	self._maid:GiveTask(invokePlacement.OnServerEvent:Connect(function(player, func, ...)
		if (placementObjects[player]) then
			placementClass[func](placementObjects[player], ...)
		end
	end))

	function dsPlacement.OnServerInvoke(player, saving, useData)
		local key = "player_"..player.UserId
		
		local success, result = pcall(function()
			if (saving and placementObjects[player]) then
				if (useData) then
					datastore:SetAsync(key, placementObjects[player]:Serialize())
				else
					datastore:SetAsync(key, {})
				end
			elseif (not saving) then
				return datastore:GetAsync(key)
			end
		end)
		
		if (success) then
			return saving or result
		else
			warn(result)
		end
	end
end

return BuildServer
