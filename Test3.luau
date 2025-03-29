local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:FindFirstChild("PlayerGui") or Instance.new("PlayerGui", player)

-- UI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 200)
mainFrame.Position = UDim2.new(0.5, -175, 0.4, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Rounded Corners
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 15)
uiCorner.Parent = mainFrame

-- Gradient Outline
local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = 4
uiStroke.Parent = mainFrame

-- Gradient Animation
local gradient = Instance.new("UIGradient")
gradient.Parent = uiStroke
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 0)), 
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 20, 0))
}
gradient.Rotation = 0

-- Smooth Gradient Animation
local function animateGradient()
    local tween = TweenService:Create(gradient, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360})
    tween:Play()
end
animateGradient()

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "Fruit Finder"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20
title.Parent = mainFrame

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 50)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.Text = "Status: Searching..."
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 16
statusLabel.Parent = mainFrame

-- Fruit Name
local fruitLabel = Instance.new("TextLabel")
fruitLabel.Size = UDim2.new(1, -20, 0, 30)
fruitLabel.Position = UDim2.new(0, 10, 0, 90)
fruitLabel.BackgroundTransparency = 1
fruitLabel.Font = Enum.Font.GothamMedium
fruitLabel.Text = "Fruit: ???"
fruitLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
fruitLabel.TextSize = 16
fruitLabel.Parent = mainFrame

-- Distance Label
local distanceLabel = Instance.new("TextLabel")
distanceLabel.Size = UDim2.new(1, -20, 0, 30)
distanceLabel.Position = UDim2.new(0, 10, 0, 130)
distanceLabel.BackgroundTransparency = 1
distanceLabel.Font = Enum.Font.GothamMedium
distanceLabel.Text = "Distance: ???"
distanceLabel.TextColor3 = Color3.fromRGB(255, 150, 50)
distanceLabel.TextSize = 16
distanceLabel.Parent = mainFrame

-- Credit Label
local creditLabel = Instance.new("TextLabel")
creditLabel.Size = UDim2.new(1, -20, 0, 20)
creditLabel.Position = UDim2.new(0, 10, 0, 170)
creditLabel.BackgroundTransparency = 1
creditLabel.Font = Enum.Font.GothamItalic
creditLabel.Text = "Made by R3nderDV. On Discord"
creditLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
creditLabel.TextSize = 14
creditLabel.Parent = mainFrame

-- Function to Find the Nearest Fruit
local function findNearestFruit()
    local nearestFruit = nil
    local shortestDistance = math.huge
    local playerPosition = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position
    
    if not playerPosition then
        return nil
    end

    for _, fruit in pairs(Workspace:GetChildren()) do
        if fruit:IsA("Model") and fruit:FindFirstChild("Fruit") then
            local fruitPosition = fruit.Fruit.Position
            local distance = (playerPosition - fruitPosition).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                nearestFruit = fruit
            end
        end
    end

    return nearestFruit, shortestDistance
end

-- Function to Update UI with Fruit Information
local function updateUI()
    local fruit, distance = findNearestFruit()

    if fruit then
        statusLabel.Text = "Status: Fruit Found!"
        fruitLabel.Text = "Fruit: " .. fruit.Name
        distanceLabel.Text = "Distance: " .. math.floor(distance) .. "m"
    else
        statusLabel.Text = "Status: Searching..."
        fruitLabel.Text = "Fruit: ???"
        distanceLabel.Text = "Distance: ???"
    end
end

-- Continuous Search for Fruits
while true do
    updateUI()
    task.wait(3) -- Updates every 3 seconds
end
