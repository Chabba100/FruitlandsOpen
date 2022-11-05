--[=[
	@class GameServiceServer
]=]

local require = require(script.Parent.loader).load(script)

local PermissionProviderUtils = require("PermissionProviderUtils")
local CmdrService = require("CmdrService")

local GameServiceServer = {}

function GameServiceServer:Init(serviceBag)
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External
	self._serviceBag:GetService(require("IKService"))

	-- Internal
	self._serviceBag:GetService(require("GameBindersServer"))
	--self._serviceBag:GetService(require("BuildServer"))
end

return GameServiceServer
