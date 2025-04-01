-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

-- Player
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local camera = Workspace.CurrentCamera

-- UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.3, 0, 0.08, 0)
frame.Position = UDim2.new(0.35, 0, 0.01, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Parent = screenGui
frame.ClipsDescendants = true
frame.ZIndex = 1
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0.2, 0)
uiCorner.Parent = frame
local fruitLabel = Instance.new("TextLabel")
fruitLabel.Size = UDim2.new(1, 0, 1, 0)
fruitLabel.BackgroundTransparency = 1
fruitLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fruitLabel.TextScaled = true
fruitLabel.Font = Enum.Font.GothamBold
fruitLabel.TextStrokeTransparency = 0
fruitLabel.TextStrokeColor3 = Color3.fromRGB(50, 50, 50)
fruitLabel.ZIndex = 2
fruitLabel.Parent = frame

-- List of fruits
local fruitsList = { "Fruit ", "Rocket Fruit", "Spin Fruit", "Ghost Fruit", "Spring Fruit", "Bomb Fruit", "Spike Fruit", "Smoke Fruit", "Blade Fruit", "Sand Fruit", "Ice Fruit", "Dark Fruit", "Diamond Fruit", "Light Fruit", "Rubber Fruit", "Barrier Fruit", "Magma Fruit", "Phoenix Fruit", "Love Fruit", "Spider Fruit", "Sound Fruit", "Buddha Fruit", "Quake Fruit", "Gravity Fruit", "Control Fruit", "T-Rex Fruit", "Mammoth Fruit", "Spirit Fruit", "Venom Fruit", "Shadow Fruit", "Rumble Fruit", "Portal Fruit", "Blizzard Fruit", "Dragon Fruit", "Leopard Fruit", "Dough Fruit", "Dragon (West) Fruit", "Dragon (East) Fruit", "Kitsune Fruit", "Gas Fruit", "Flame Fruit", "Yeti Fruit" }

-- Function to find nearest fruit
local function findNearestFruit()
    local nearestFruit = nil
    local minDistance = math.huge
    local fruitCount = 0
    for _, fruit in ipairs(Workspace:GetChildren()) do
        if table.find(fruitsList, fruit.Name) and fruit:FindFirstChild("Handle") then
            local distance = (humanoidRootPart.Position - fruit.Handle.Position).Magnitude
            fruitCount = fruitCount + 1
            if distance < minDistance then
                minDistance = distance
                nearestFruit = fruit
            end
        end
    end
    return nearestFruit, minDistance, fruitCount
end

-- Update UI every 0.05 seconds
spawn(function()
    while true do
        local nearestFruit, distance, fruitCount = findNearestFruit()
        if nearestFruit then
            fruitLabel.Text = "🍌 Nearest: " .. nearestFruit.Name .. " | 🚩 Distance: " .. math.floor(distance) .. "⚡ Total Fruits: " .. fruitCount
        else
            fruitLabel.Text = "No fruits found in server 🚩"
        end
        task.wait(0.05)
    end
end)

-- Function to move the entire character to the nearest fruit with a tween
local function teleportToNearestFruit()
    local nearestFruit, minDistance = findNearestFruit()
    if nearestFruit then
        -- Calculate the time to cover the distance at 200 studs per second
        local time = minDistance / 200
        local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        
        -- Tween the HumanoidRootPart's CFrame to the nearest fruit's position
        local targetCFrame = CFrame.new(nearestFruit.Handle.Position)
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetCFrame})
        
        -- Lock the camera to follow the humanoid root part during tweening
        local connection
        connection = RunService.RenderStepped:Connect(function()
            camera.CFrame = humanoidRootPart.CFrame
        end)
        
        tween.Completed:Connect(function()
            connection:Disconnect()
        end)
        
        tween:Play()
    end
end

-- TP Button
local tpButton = Instance.new("TextButton")
tpButton.Size = UDim2.new(0.1, 0, 0.08, 0)
tpButton.Position = UDim2.new(0.12, 0, 0.01, 0)
tpButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
tpButton.Text = "TP"
tpButton.Font = Enum.Font.GothamBold
tpButton.TextScaled = true
tpButton.TextColor3 = Color3.new(1, 1, 1)
tpButton.Parent = screenGui
local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = UDim.new(1, 0)
tpCorner.Parent = tpButton
tpButton.MouseButton1Click:Connect(teleportToNearestFruit)
