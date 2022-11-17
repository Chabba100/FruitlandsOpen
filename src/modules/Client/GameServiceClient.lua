--[=[
	@class GameServiceClient
]=]

local require = require(script.Parent.loader).load(script)

local GameServiceClient = {}
GameServiceClient.ServiceName = "GameServiceClient"

function GameServiceClient:Init(serviceBag)
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External
	self._serviceBag:GetService(require("CameraStackService"))
	self._serviceBag:GetService(require("IKServiceClient")):SetLookAround(true)
	self._serviceBag:GetService(require("SoftShutdownServiceClient"))

	--Internal
	self._serviceBag:GetService(require("GameBindersClient"))
	self._serviceBag:GetService(require("GameTranslator"))
	self._serviceBag:GetService(require("FlashbangServiceClient"))
end

return GameServiceClient
