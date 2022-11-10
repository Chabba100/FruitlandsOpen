local require = require(script.Parent.loader).load(script)

local PlayerDataStoreService = require("PlayerDataStoreService")

local Players = game:GetService("Players")

local DataService = {}

function DataService:Init(serviceBag)
	self._serviceBag = assert(serviceBag, "No serviceBag")
    self._playerDataStoreService = self._serviceBag:GetService(PlayerDataStoreService)
end

function DataService:Start()
end


return DataService
