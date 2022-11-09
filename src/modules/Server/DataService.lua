local require = require(script.Parent.loader).load(script)

local ProfileService = require("ProfileService")

local Players = game:GetService("Players")

local DataService = {}

local ProfileTemplate = {
    Gold = 10;
    House = {};
}
local ProfileStore = ProfileService.GetProfileStore("PlayerData", ProfileTemplate)

function DataService:Init(serviceBag)
	self._serviceBag = assert(serviceBag, "No serviceBag")

    print("service loaded!")
    self._profiles = {}
end

function DataService:Start()
	for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(function()
            self:_playerAdded(player)
        end)
    end
    Players.PlayerAdded:Connect(function(player)
        self:_playerAdded(player)
    end)
    Players.PlayerRemoving:Connect(function(player)
        local profile = self._profiles[player]
        if profile ~= nil then
            profile:Release()
        end
    end)
end

function DataService:_playerAdded(player: Player)
    local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)
    if profile ~= nil then
        profile:AddUserId(player.UserId)
        profile:Reconcile()
        profile:ListenToRelease(function()
            self._profiles[player] = nil
            -- The profile could've been loaded on another Roblox server:
            player:Kick()
        end)
        if player:IsDescendantOf(Players) == true then
            self._profiles[player] = profile
            -- A profile has been successfully loaded:
            print("loaded successfully!")
        else
            -- Player left before the profile loaded:
            profile:Release()
        end
    else
        -- The profile couldn't be loaded possibly due to other
        --   Roblox servers trying to load this profile at the same time:
        player:Kick()
    end
end

function DataService:_getPlayerProfileAsync(player)
    -- Yields until a Profile linked to a player is loaded or the player leaves
    local profile = self._profiles[player]
    while profile == nil and player:IsDescendantOf(Players) == true do
        task.wait()
        profile = self._profiles[player]
    end
    return profile
end

return DataService
