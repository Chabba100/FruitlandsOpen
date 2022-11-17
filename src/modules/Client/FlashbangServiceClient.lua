local require = require(script.Parent.loader).load(script)

local Blend = require("Blend")
local Maid = require("Maid")
local PromiseGetRemoteEvent = require("PromiseGetRemoteEvent")

local Players = game:GetService("Players")

local FlashbangServiceClient = {}
FlashbangServiceClient.ServiceName = "FlashbangServiceClient"

function FlashbangServiceClient:Init(serviceBag)
	self._serviceBag = assert(serviceBag, "No serviceBag")

    self._maid = Maid.new()
end

function FlashbangServiceClient:Start()
    local percentVisible = Blend.State(1)
    self._maid:GiveTask((Blend.New "ScreenGui" {
        Name = "Flashbang";
        IgnoreGuiInset = true;

        [Blend.Children] = {
            Blend.New "Frame" {
                Name = "Flashbang";
                Size = UDim2.fromScale(1, 1);
                BackgroundTransparency = Blend.Spring(percentVisible, 30)
            }
        }
    }):Subscribe(function(gui)
        gui.Parent = Players.LocalPlayer.PlayerGui
        PromiseGetRemoteEvent("flashbang"):Then(function(event)
            self._maid:GiveTask(event.OnClientEvent:Connect(function()
                percentVisible.Value = 0
                task.delay(0.2, function()
                    percentVisible.Value = 1
                end)
            end))
        end)
    end))
end

return FlashbangServiceClient
