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
    local tween = TweenService:Create(humanoidRootPart, TweenInfo.new(tweenTime), {CFrame = CFrame.new(targetPos)})
    tween:Play()
    tween.Completed:Connect(function()
        isTweening = false
    end)
end

-- UI Setup
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local canvas = Instance.new("Frame", gui)
canvas.Size = UDim2.new(1, 0, 1, 0)
canvas.BackgroundTransparency = 1

-- Top Bar UI
local topBar = Instance.new("Frame", canvas)
topBar.Size = UDim2.new(1, 0, 0, 60)
topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
topBar.BorderSizePixel = 0

-- Buttons
local function createToggle(name, position)
    local button = Instance.new("TextButton", topBar)
    button.Size = UDim2.new(0, 100, 0, 40)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.new(1,1,1)
    button.Text = name
    button.AutoButtonColor = false
    local corner = Instance.new("UICorner", button)
    corner.CornerRadius = UDim.new(1, 0)

    button.MouseButton1Click:Connect(function()
        toggleStates[name] = not toggleStates[name]
        button.BackgroundColor3 = toggleStates[name] and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(50, 50, 50)
    end)
end

createToggle("Tween", UDim2.new(0, 150, 0, 10))
createToggle("ESP", UDim2.new(0, 250, 0, 10))
createToggle("AutoStore", UDim2.new(1, -370, 0, 10))
createToggle("Placeholder", UDim2.new(1, -260, 0, 10))

-- Circular GUI Toggle Button
local guiButton = Instance.new("TextButton", topBar)
guiButton.Size = UDim2.new(0, 40, 0, 40)
guiButton.Position = UDim2.new(0.5, -20, 0, 10)
guiButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
guiButton.Text = "≡"
local guiCorner = Instance.new("UICorner", guiButton)
guiCorner.CornerRadius = UDim.new(1, 0)

-- Side Panel for fruits
local fruitPanel = Instance.new("Frame", canvas)
fruitPanel.Size = UDim2.new(0, 320, 1, 0)
fruitPanel.Position = UDim2.new(-1, 0, 0, 0)
fruitPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
fruitPanel.ClipsDescendants = true
local panelCorner = Instance.new("UICorner", fruitPanel)
panelCorner.CornerRadius = UDim.new(0, 20)

-- Fruit Slots
local slots = {}
for i = 1, 6 do
    local slot = Instance.new("Frame", fruitPanel)
    slot.Size = UDim2.new(1, -20, 0, 40)
    slot.Position = UDim2.new(0, 10, 0, (i - 1) * 50 + 20)
    slot.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    local corner = Instance.new("UICorner", slot)
    corner.CornerRadius = UDim.new(0, 12)

    local label = Instance.new("TextLabel", slot)
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextScaled = true

    local tpButton = Instance.new("TextButton", slot)
    tpButton.Size = UDim2.new(0, 50, 0, 30)
    tpButton.Position = UDim2.new(1, -55, 0.5, -15)
    tpButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    tpButton.TextColor3 = Color3.new(1, 1, 1)
    tpButton.Text = "TP"
    local tpCorner = Instance.new("UICorner", tpButton)
    tpCorner.CornerRadius = UDim.new(1, 0)

    slots[i] = {frame = slot, label = label, button = tpButton}
end

local open = false
guiButton.MouseButton1Click:Connect(function()
    open = not open
    TweenService:Create(fruitPanel, TweenInfo.new(1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = open and UDim2.new(0, 0, 0, 0) or UDim2.new(-1, 0, 0, 0)
    }):Play()
end)

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
