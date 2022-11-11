local require = require(script.Parent.loader).load(script)

local CollectionService = game:GetService("CollectionService")

local FruitUtil = {}

function FruitUtil.canPickup(character: Model)
    for _, part in pairs(character:GetDescendants()) do
        if CollectionService:HasTag(part, "Fruit") then
            return false
        end
    end
    return true
end

return FruitUtil