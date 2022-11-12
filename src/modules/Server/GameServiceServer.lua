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
	self._serviceBag:GetService(require("SoftShutdownService"))

	-- Internal
	self._serviceBag:GetService(require("GameBindersServer"))
end

return GameServiceServer
