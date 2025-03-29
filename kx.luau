local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Create UI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui")

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0.3, 0, 0.1, 0)
infoLabel.Position = UDim2.new(0.35, 0, 0, 0)
infoLabel.BackgroundTransparency = 0.5
infoLabel.TextScaled = true
infoLabel.TextColor3 = Color3.new(1, 1, 1)
infoLabel.Parent = screenGui

local function getNearestFruit()
    local fruits = {}
    for _, fruitName in {
        "Fruit ", "Rocket Fruit", "Spin Fruit", "Ghost Fruit", "Spring Fruit", "Bomb Fruit", "Spike Fruit",
        "Smoke Fruit", "Blade Fruit", "Sand Fruit", "Ice Fruit", "Dark Fruit", "Diamond Fruit", "Light Fruit",
        "Rubber Fruit", "Barrier Fruit", "Magma Fruit", "Phoenix Fruit", "Love Fruit", "Spider Fruit",
        "Sound Fruit", "Buddha Fruit", "Quake Fruit", "Gravity Fruit", "Control Fruit", "T-Rex Fruit",
        "Mammoth Fruit", "Spirit Fruit", "Venom Fruit", "Shadow Fruit", "Rumble Fruit", "Portal Fruit",
        "Blizzard Fruit", "Dragon Fruit", "Leopard Fruit", "Dough Fruit", "Dragon (West) Fruit",
        "Dragon (East) Fruit", "Kitsune Fruit", "Gas Fruit", "Yeti Fruit"
    } do
        local fruit = Workspace:FindFirstChild(fruitName)
        if fruit and fruit:FindFirstChild("Handle") then
            table.insert(fruits, fruit.Handle)
        end
    end
    
    local nearestFruit, nearestDistance = nil, math.huge
    for _, fruit in ipairs(fruits) do
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local distance = (character.HumanoidRootPart.Position - fruit.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestFruit = fruit
            end
        end
        
        -- Highlight fruits through walls
        if not fruit:FindFirstChild("Highlight") then
            local highlight = Instance.new("Highlight")
            highlight.Parent = fruit
            highlight.FillColor = Color3.fromRGB(255, 255, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end
    end
    
    return nearestFruit, nearestDistance, #fruits
end

local function updateUI()
    local nearestFruit, distance, count = getNearestFruit()
    if nearestFruit then
        infoLabel.Text = string.format("Nearest Fruit: %s\nDistance: %.2f\nTotal Fruits: %d", nearestFruit.Parent.Name, distance, count)
    else
        infoLabel.Text = "No fruits found"
    end
end

RunService.RenderStepped:Connect(updateUI)
