local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

-- UI References
local ui = script.Parent
local nameLabel = ui:FindFirstChild("NameLabel")
local countLabel = ui:FindFirstChild("CountLabel")

-- List of all possible fruits
local fruitsList = {
    "Fruit ", "Rocket Fruit", "Spin Fruit", "Ghost Fruit", "Spring Fruit", "Bomb Fruit", "Spike Fruit",
    "Smoke Fruit", "Blade Fruit", "Sand Fruit", "Ice Fruit", "Dark Fruit", "Diamond Fruit", "Light Fruit",
    "Rubber Fruit", "Barrier Fruit", "Magma Fruit", "Phoenix Fruit", "Love Fruit", "Spider Fruit",
    "Sound Fruit", "Buddha Fruit", "Quake Fruit", "Gravity Fruit", "Control Fruit", "T-Rex Fruit",
    "Mammoth Fruit", "Spirit Fruit", "Venom Fruit", "Shadow Fruit", "Rumble Fruit", "Portal Fruit",
    "Blizzard Fruit", "Dragon Fruit", "Leopard Fruit", "Dough Fruit", "Dragon (West) Fruit",
    "Dragon (East) Fruit", "Kitsune Fruit", "Gas Fruit", "Yeti Fruit"
}

-- Function to get nearest fruit
local function getNearestFruit()
    local nearestFruit = nil
    local shortestDistance = math.huge
    local totalFruits = 0

    for _, fruitName in ipairs(fruitsList) do
        for _, fruit in ipairs(game.Workspace:GetChildren()) do
            if fruit.Name == fruitName and fruit:FindFirstChild("Handle") then
                local fruitPosition = fruit.Handle.Position
                local distance = (rootPart.Position - fruitPosition).Magnitude
                totalFruits += 1

                if distance < shortestDistance then
                    shortestDistance = distance
                    nearestFruit = fruitName
                end
            end
        end
    end

    return nearestFruit, shortestDistance, totalFruits
end

-- UI Update Loop
task.spawn(function()
    while true do
        local fruitName, fruitDistance, fruitCount = getNearestFruit()

        -- Update UI
        if fruitName then
            nameLabel.Text = "🍏 Nearest Fruit: " .. fruitName .. " | " .. math.floor(fruitDistance) .. "m"
        else
            nameLabel.Text = "❌ No fruit detected!"
        end

        countLabel.Text = "🍇 Fruits Found: " .. fruitCount

        task.wait(0.06) -- Update every 0.06 seconds
    end
end)
