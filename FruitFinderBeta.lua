-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")

-- Player and Character Setup
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Fruits List from GitHub script
local fruitsList = {
    "Fruit ", "Rocket Fruit", "Spin Fruit", "Ghost Fruit", "Spring Fruit", "Bomb Fruit",
    "Spike Fruit", "Smoke Fruit", "Blade Fruit", "Sand Fruit", "Ice Fruit", "Dark Fruit",
    "Diamond Fruit", "Light Fruit", "Rubber Fruit", "Barrier Fruit", "Magma Fruit", "Phoenix Fruit",
    "Love Fruit", "Spider Fruit", "Sound Fruit", "Buddha Fruit", "Quake Fruit", "Gravity Fruit",
    "Control Fruit", "T-Rex Fruit", "Mammoth Fruit", "Spirit Fruit", "Venom Fruit", "Shadow Fruit",
    "Rumble Fruit", "Portal Fruit", "Blizzard Fruit", "Dragon Fruit", "Leopard Fruit", "Dough Fruit",
    "Dragon (West) Fruit", "Dragon (East) Fruit", "Kitsune Fruit", "Gas Fruit", "Flame Fruit",
    "Yeti Fruit", "Creation Fruit", "Eagle Fruit"
}

-- Toggle States
local toggleStates = {
    Tween = false,
    ESP = false,
    AutoStore = false,
    Placeholder = false
}

-- Tweening setup
local isTweening = false
local function tweenToPosition(targetPos)
    if isTweening then return end
    isTweening = true
    local distance = (humanoidRootPart.Position - targetPos).Magnitude
    local tweenTime = distance / 250
    local tween = TweenService:Create(humanoidRootPart, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
    tween:Play()
    tween.Completed:Connect(function()
        isTweening = false
    end)
end

-- Rewritten GUI for FruitFinderBeta.lua with kx.luau visual design
-- Functionality (toggles, fruit list, tween, etc.) remains intact

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local toggleStates = {
    Tween = true,
    ESP = true,
    AutoStore = false,
    Placeholder = false,
}

-- Destroy existing GUI if it exists
local existingGUI = LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("FruitFinderGUI")
if existingGUI then existingGUI:Destroy() end

-- Create GUI
local gui = Instance.new("ScreenGui")
gui.Name = "FruitFinderGUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 360, 0, 240)
mainFrame.Position = UDim2.new(0.5, -180, 0.5, -120)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = mainFrame

local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = 1.5
uiStroke.Color = Color3.fromRGB(150, 0, 0)
uiStroke.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Fruit Finder GUI"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

-- Toggle Button Template
local function createToggle(name, position)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 140, 0, 32)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.Text = name
    button.AutoButtonColor = false
    button.Parent = mainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button

    button.MouseButton1Click:Connect(function()
        toggleStates[name] = not toggleStates[name]
        local newColor = toggleStates[name] and Color3.fromRGB(100, 0, 0) or Color3.fromRGB(150, 0, 0)
        TweenService:Create(button, TweenInfo.new(0.25), {
            BackgroundColor3 = newColor
        }):Play()
    end)
end

-- Create Toggles
createToggle("Tween", UDim2.new(0, 20, 0, 60))
createToggle("ESP", UDim2.new(0, 200, 0, 60))
createToggle("AutoStore", UDim2.new(0, 20, 0, 100))
createToggle("Placeholder", UDim2.new(0, 200, 0, 100))

-- Fruits Frame
local fruitFrame = Instance.new("ScrollingFrame")
fruitFrame.Size = UDim2.new(1, -20, 0, 80)
fruitFrame.Position = UDim2.new(0, 10, 0, 150)
fruitFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
fruitFrame.ScrollBarThickness = 4
fruitFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
fruitFrame.BorderSizePixel = 0
fruitFrame.Parent = mainFrame

local fruitCorner = Instance.new("UICorner")
fruitCorner.CornerRadius = UDim.new(0, 12)
fruitCorner.Parent = fruitFrame

-- Fruit Entry Template
local function createFruitEntry(fruitName, fruitPosition)
    local entry = Instance.new("TextButton")
    entry.Size = UDim2.new(1, -10, 0, 28)
    entry.Position = UDim2.new(0, 5, 0, #fruitFrame:GetChildren() * 30)
    entry.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    entry.Text = fruitName
    entry.TextColor3 = Color3.fromRGB(255, 255, 255)
    entry.Font = Enum.Font.GothamBold
    entry.TextSize = 13
    entry.AutoButtonColor = false
    entry.Parent = fruitFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = entry

    entry.MouseButton1Click:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(fruitPosition)
        end
    end)

    fruitFrame.CanvasSize = UDim2.new(0, 0, 0, #fruitFrame:GetChildren() * 30)
end

-- ESP Logic
RunService.RenderStepped:Connect(function()
    if toggleStates.ESP then
        for _, fruit in ipairs(Workspace:GetChildren()) do
            if table.find(fruitsList, fruit.Name) and fruit:FindFirstChild("Handle") and not fruit:FindFirstChild("ESP") then
                local bb = Instance.new("BillboardGui", fruit)
                bb.Name = "ESP"
                bb.Size = UDim2.new(0, 100, 0, 50)
                bb.Adornee = fruit.Handle
                bb.AlwaysOnTop = true
                local text = Instance.new("TextLabel", bb)
                text.Size = UDim2.new(1, 0, 1, 0)
                text.Text = (fruit.Name == "Fruit " and "Spawned Fruit" or fruit.Name)
                text.TextColor3 = Color3.new(1, 1, 1)
                text.BackgroundTransparency = 1
                text.Font = Enum.Font.Gotham
                text.TextScaled = true
            end
        end
    end
end)

-- Tweening Logic
RunService.Heartbeat:Connect(function()
    if toggleStates.Tween then
        local closest, dist = nil, math.huge
        for _, fruit in ipairs(Workspace:GetChildren()) do
            if table.find(fruitsList, fruit.Name) and fruit:FindFirstChild("Handle") then
                local d = (humanoidRootPart.Position - fruit.Handle.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = fruit
                end
            end
        end
        if closest then
            tweenToPosition(closest.Handle.Position)
        end
    end
end)

-- AutoStore Stub
RunService.Heartbeat:Connect(function()
    if toggleStates.AutoStore then
        for _, fruit in ipairs(Workspace:GetChildren()) do
            if table.find(fruitsList, fruit.Name) and not CollectionService:HasTag(fruit, "Stored") then
                CollectionService:AddTag(fruit, "Stored")
                -- Store logic placeholder
            end
        end
    end
end)

-- Update Fruit Slots
RunService.Heartbeat:Connect(function()
    local fruitData = {}
    for _, fruit in ipairs(Workspace:GetChildren()) do
        if table.find(fruitsList, fruit.Name) and fruit:FindFirstChild("Handle") then
            local key = fruit.Name
            fruitData[key] = fruitData[key] or {count = 0, nearest = fruit, dist = math.huge}
            local d = (humanoidRootPart.Position - fruit.Handle.Position).Magnitude
            fruitData[key].count += 1
            if d < fruitData[key].dist then
                fruitData[key].nearest = fruit
                fruitData[key].dist = d
            end
        end
    end

    local index = 1
    for name, data in pairs(fruitData) do
        if index <= #slots then
            local slot = slots[index]
            slot.label.Text = string.format("%dx %s (%.1f)", data.count, name, data.dist)
            slot.button.MouseButton1Click:Connect(function()
                tweenToPosition(data.nearest.Handle.Position)
            end)
            index += 1
        end
    end
    for i = index, #slots do
        slots[i].label.Text = ""
    end
end)
