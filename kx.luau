local players = game:GetService("Players")
local runService = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local player = players.LocalPlayer

-- Create the UI
local gui = Instance.new("ScreenGui")
gui.Name = "FruitNotifier"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 100)
frame.Position = UDim2.new(0.05, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
frame.Parent = gui
frame.ClipsDescendants = true
frame.BackgroundTransparency = 0.2
frame.Active = true
frame.Draggable = true
frame.CornerRadius = UDim.new(0, 10)

-- Title
local title = Instance.new("TextLabel")
title.Text = "📍 Fruit Notifier"
title.Size = UDim2.new(1, 0, 0, 20)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true
title.Parent = frame

-- Info labels
local totalFruits = Instance.new("TextLabel")
totalFruits.Size = UDim2.new(1, 0, 0, 20)
totalFruits.Position = UDim2.new(0, 0, 0, 25)
totalFruits.BackgroundTransparency = 1
totalFruits.TextColor3 = Color3.fromRGB(255, 255, 255)
totalFruits.Font = Enum.Font.SourceSans
totalFruits.TextScaled = true
totalFruits.Parent = frame

local nearestFruit = Instance.new("TextLabel")
nearestFruit.Size = UDim2.new(1, 0, 0, 20)
nearestFruit.Position = UDim2.new(0, 0, 0, 50)
nearestFruit.BackgroundTransparency = 1
nearestFruit.TextColor3 = Color3.fromRGB(255, 255, 255)
nearestFruit.Font = Enum.Font.SourceSans
nearestFruit.TextScaled = true
nearestFruit.Parent = frame

local distanceLabel = Instance.new("TextLabel")
distanceLabel.Size = UDim2.new(1, 0, 0, 20)
distanceLabel.Position = UDim2.new(0, 0, 0, 75)
distanceLabel.BackgroundTransparency = 1
distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
distanceLabel.Font = Enum.Font.SourceSans
distanceLabel.TextScaled = true
distanceLabel.Parent = frame

-- Fruit List
local fruitsList = {
    "Fruit ", "Rocket Fruit", "Spin Fruit", "Ghost Fruit", "Spring Fruit", "Bomb Fruit", "Spike Fruit",
    "Smoke Fruit", "Blade Fruit", "Sand Fruit", "Ice Fruit", "Dark Fruit", "Diamond Fruit", "Light Fruit",
    "Rubber Fruit", "Barrier Fruit", "Magma Fruit", "Phoenix Fruit", "Love Fruit", "Spider Fruit",
    "Sound Fruit", "Buddha Fruit", "Quake Fruit", "Gravity Fruit", "Control Fruit", "T-Rex Fruit",
    "Mammoth Fruit", "Spirit Fruit", "Venom Fruit", "Shadow Fruit", "Rumble Fruit", "Portal Fruit",
    "Blizzard Fruit", "Dragon Fruit", "Leopard Fruit", "Dough Fruit", "Dragon (West) Fruit",
    "Dragon (East) Fruit", "Kitsune Fruit", "Gas Fruit", "Yeti Fruit"
}

-- Function to update the UI
local function updateFruitInfo()
    while true do
        local total = 0
        local nearestFruitName = "None"
        local nearestDistance = math.huge
        local playerPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

        if playerPos then
            for _, fruitName in ipairs(fruitsList) do
                local fruit = workspace:FindFirstChild(fruitName)
                if fruit and fruit:FindFirstChild("Handle") then
                    total = total + 1
                    local fruitPos = fruit.Handle.Position
                    local distance = (playerPos.Position - fruitPos).Magnitude

                    if distance < nearestDistance then
                        nearestDistance = distance
                        nearestFruitName = fruitName
                    end
                end
            end
        end

        -- Update UI
        totalFruits.Text = "📍 Fruits in Server: " .. total
        nearestFruit.Text = "🍎 Nearest: " .. nearestFruitName
        distanceLabel.Text = "🔍 Distance: " .. math.floor(nearestDistance) .. " studs"

        task.wait(0.04) -- Updates every 0.04 seconds
    end
end

-- Run the update function in a separate thread
task.spawn(updateFruitInfo)
