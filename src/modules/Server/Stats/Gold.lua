local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local PlayerDataStoreService = require("PlayerDataStoreService")

local Gold = setmetatable({}, BaseObject)
Gold.ClassName = "Gold"
Gold.__index = Gold

function Gold.new(obj, serviceBag)
    local self = setmetatable(BaseObject.new(obj), Gold)

    self._serviceBag = assert(serviceBag, "No serviceBag")
    self._playerDataStoreService = self._serviceBag:GetService(PlayerDataStoreService)

    self._maid:GivePromise(self._playerDataStoreService:PromiseDataStore(self._obj))
        :Then(function(dataStore)
            return self._maid:GivePromise(dataStore:Load("gold", 10))
                :Then(function(amount)
                    local goldValue = Instance.new("IntValue")
                    goldValue.Name = "Gold"
                    goldValue.Value = amount
                    goldValue.Parent = self._obj

                    self._maid:GiveTask(dataStore:StoreOnValueChange("gold", goldValue))
                    self._maid:GiveTask(goldValue)
                end)
        end)

    return self
end

return Gold