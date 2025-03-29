-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Player
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
then
local function JoinTeam()
    if plr.Team ~= game.Teams.Marines and plr.Team ~= game.Teams.Pirates then
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("SetTeam", "Marines")
    end
end

JoinTeam()

-- UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, 0, 0.08, 0) -- Reduced height for better UI fitting
frame.Position = UDim2.new(0, 0, 0, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.2 -- Slightly reduced transparency for better visibility
frame.BorderSizePixel = 0
frame.Parent = screenGui

local fruitLabel = Instance.new("TextLabel")
fruitLabel.Size = UDim2.new(1, 0, 1, 0)
fruitLabel.BackgroundTransparency = 1
fruitLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fruitLabel.TextScaled = true
fruitLabel.Font = Enum.Font.GothamBold -- Changed font for better readability
fruitLabel.TextStrokeTransparency = 0.5
fruitLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
fruitLabel.Parent = frame

-- List of fruits
local fruitsList = {
    "Fruit", "Rocket Fruit", "Spin Fruit", "Ghost Fruit", "Spring Fruit", "Bomb Fruit", "Spike Fruit",
    "Smoke Fruit", "Blade Fruit", "Sand Fruit", "Ice Fruit", "Dark Fruit", "Diamond Fruit", "Light Fruit",
    "Rubber Fruit", "Barrier Fruit", "Magma Fruit", "Phoenix Fruit", "Love Fruit", "Spider Fruit",
    "Sound Fruit", "Buddha Fruit", "Quake Fruit", "Gravity Fruit", "Control Fruit", "T-Rex Fruit",
    "Mammoth Fruit", "Spirit Fruit", "Venom Fruit", "Shadow Fruit", "Rumble Fruit", "Portal Fruit",
    "Blizzard Fruit", "Dragon Fruit", "Leopard Fruit", "Dough Fruit", "Dragon (West) Fruit",
    "Dragon (East) Fruit", "Kitsune Fruit", "Gas Fruit", "Yeti Fruit"
}

-- Function to find nearest fruit
local function findNearestFruit()
    local nearestFruit = nil
    local minDistance = math.huge
    local fruitCount = 0
    
    for _, fruitName in ipairs(fruitsList) do
        for _, fruit in ipairs(Workspace:GetChildren()) do
            if fruit.Name == fruitName and fruit:FindFirstChild("Handle") then
                local distance = (humanoidRootPart.Position - fruit.Handle.Position).Magnitude
                fruitCount = fruitCount + 1
                
                if distance < minDistance then
                    minDistance = distance
                    nearestFruit = fruit
                end
                
                -- Highlighting fruit through walls
                local highlight = fruit:FindFirstChild("Highlight") or Instance.new("Highlight")
                highlight.Parent = fruit
                highlight.FillColor = Color3.fromRGB(255, 255, 0)
                highlight.FillTransparency = 0.3 -- Reduced transparency for better visibility
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.OutlineTransparency = 0
            end
        end
    end
    
    return nearestFruit, minDistance, fruitCount
end

-- Update UI every 0.06 seconds
RunService.RenderStepped:Connect(function()
    local nearestFruit, distance, fruitCount = findNearestFruit()
    if nearestFruit then
        fruitLabel.Text = "🍏 Nearest: " .. nearestFruit.Name .. " | 📏 Distance: " .. math.floor(distance) .. "m\n🍎 Total Fruits: " .. fruitCount
    else
        fruitLabel.Text = "❌ No fruits found"
    end
end)
