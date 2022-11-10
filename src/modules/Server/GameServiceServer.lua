--[=[
	@class GameServiceServer
]=]

local require = require(script.Parent.loader).load(script)

local PlayerDataStoreService = require("PlayerDataStoreService")

local GameServiceServer = {}

function GameServiceServer:Init(serviceBag)
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External
	self._serviceBag:GetService(require("IKService"))
	self._serviceBag:GetService(require("PlayerDataStoreService"))

	-- Internal
	self._serviceBag:GetService(require("GameBindersServer"))
	--self._serviceBag:GetService(require("DataService"))
	--self._serviceBag:GetService(require("BuildServer"))
end

return GameServiceServer
