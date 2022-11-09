local require = require(script.Parent.loader).load(script)

local ProfileService = require("ProfileService")

local Players = require("Players")

local DataService = {}

local ProfileTemplate = {
    Gold = 10;
    House = {};
}

function DataService:Init(serviceBag)
	self._serviceBag = assert(serviceBag, "No serviceBag")

    print("service loaded!")
    self._profiles = {}
end

function DataService:Start()
	for _, player in ipairs(Players:GetPlayers()) do
        
    end
end

function DataService:_playerAdded()
    
end

return DataService
