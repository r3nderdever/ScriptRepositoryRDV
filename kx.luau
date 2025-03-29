local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "FruitNotifier"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Create Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 100)
frame.Position = UDim2.new(0.05, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

-- Rounded Corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Text = "📍 Fruit Notifier"
title.Size = UDim2.new(1, 0, 0, 20)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true
title.Parent = frame

-- Labels
local totalFruits = Instance.new("TextLabel")
totalFruits.Text = "📍 Fruits in Server: 0"
totalFruits.Size = UDim2.new(1, 0, 0, 20)
totalFruits.Position = UDim2.new(0, 0, 0, 25)
totalFruits.BackgroundTransparency = 1
totalFruits.TextColor3 = Color3.fromRGB(255, 255, 255)
totalFruits.Font = Enum.Font.SourceSans
totalFruits.TextScaled = true
totalFruits.Parent = frame

local nearestFruit = Instance.new("TextLabel")
nearestFruit.Text = "🍎 Nearest: None"
nearestFruit.Size = UDim2.new(1, 0, 0, 20)
nearestFruit.Position = UDim2.new(0, 0, 0, 50)
nearestFruit.BackgroundTransparency = 1
nearestFruit.TextColor3 = Color3.fromRGB(255, 255, 255)
nearestFruit.Font = Enum.Font.SourceSans
nearestFruit.TextScaled = true
nearestFruit.Parent = frame

local distanceLabel = Instance.new("TextLabel")
distanceLabel.Text = "🔍 Distance: 0 studs"
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

-- Function to find fruits
local function updateFruitInfo()
    while true do
        local total = 0
        local nearestFruitName = "None"
        local nearestDistance = math.huge
        local playerPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

        if playerPos then
            for _, fruitName in ipairs(fruitsList) do
                local fruit = Workspace:FindFirstChild(fruitName)
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

        task.wait(0.04) -- Update every 0.04 seconds
    end
end

-- Start updating in a separate thread
task.spawn(updateFruitInfo)
