-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Player
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local camera = Workspace.CurrentCamera

-- Settings file
local settingsFile = "RDVfruitNotifier201"
local function saveSettings()
    local data = {
        autoStore = autoStoreEnabled,
        esp = espEnabled
    }
    writefile(settingsFile, game:GetService("HttpService"):JSONEncode(data))
end

local function loadSettings()
    if isfile(settingsFile) then
        local raw = readfile(settingsFile)
        local success, result = pcall(function()
            return game:GetService("HttpService"):JSONDecode(raw)
        end)
        if success then
            return result
        end
    end
    return {autoStore = false, esp = false}
end

-- Load saved settings
local loaded = loadSettings()
local autoStoreEnabled = loaded.autoStore
local espEnabled = loaded.esp

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
local fruitsList = {
    "Fruit ", "Rocket Fruit", "Spin Fruit", "Ghost Fruit", "Spring Fruit", "Bomb Fruit", "Spike Fruit", "Smoke Fruit", "Blade Fruit",
    "Sand Fruit", "Ice Fruit", "Dark Fruit", "Diamond Fruit", "Light Fruit", "Rubber Fruit", "Barrier Fruit", "Magma Fruit",
    "Phoenix Fruit", "Love Fruit", "Spider Fruit", "Sound Fruit", "Buddha Fruit", "Quake Fruit", "Gravity Fruit", "Control Fruit",
    "T-Rex Fruit", "Mammoth Fruit", "Spirit Fruit", "Venom Fruit", "Shadow Fruit", "Rumble Fruit", "Portal Fruit", "Blizzard Fruit",
    "Dragon Fruit", "Leopard Fruit", "Dough Fruit", "Dragon (West) Fruit", "Dragon (East) Fruit", "Kitsune Fruit", "Gas Fruit",
    "Flame Fruit", "Yeti Fruit"
}

-- ESP Container
local espFolder = Instance.new("Folder")
espFolder.Name = "FruitESP"
espFolder.Parent = Workspace

-- Function to find nearest fruit
local function findNearestFruit()
    local nearestFruit = nil
    local minDistance = math.huge
    local fruitCount = 0
    for _, fruit in ipairs(Workspace:GetChildren()) do
        if table.find(fruitsList, fruit.Name) and fruit:FindFirstChild("Handle") then
            local distance = (humanoidRootPart.Position - fruit.Handle.Position).Magnitude
            fruitCount += 1
            if distance < minDistance then
                minDistance = distance
                nearestFruit = fruit
            end
        end
    end
    return nearestFruit, minDistance, fruitCount
end

-- Update UI
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

-- Auto Store Loop
spawn(function()
    while true do
        if autoStoreEnabled then
            pcall(function()
                for _, fr in ipairs(player.Backpack:GetChildren()) do
                    if fr:IsA("Tool") and fr.Name:find("Fruit") then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", fr:GetAttribute("OriginalName"), fr)
                    end
                end
                for _, fr in ipairs(player.Character:GetChildren()) do
                    if fr:IsA("Tool") and fr.Name:find("Fruit") then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", fr:GetAttribute("OriginalName"), fr)
                    end
                end
            end)
        end
        task.wait(1)
    end
end)

-- ESP Loop
spawn(function()
    while true do
        if espEnabled then
            for _, child in ipairs(espFolder:GetChildren()) do
                child:Destroy()
            end

            for _, fruit in ipairs(Workspace:GetChildren()) do
                if table.find(fruitsList, fruit.Name) and fruit:FindFirstChild("Handle") then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "ESP"
                    billboard.Size = UDim2.new(0, 100, 0, 40)
                    billboard.StudsOffset = Vector3.new(0, 2, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Adornee = fruit.Handle
                    billboard.Parent = espFolder

                    local label = Instance.new("TextLabel", billboard)
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = fruit.Name
                    label.TextColor3 = Color3.new(1, 1, 1)
                    label.TextScaled = true
                    label.Font = Enum.Font.GothamBold
                end
            end
        else
            for _, child in ipairs(espFolder:GetChildren()) do
                child:Destroy()
            end
        end
        task.wait(1)
    end
end)

-- Tween TP
local function teleportToNearestFruit()
    local nearestFruit, minDistance = findNearestFruit()
    if nearestFruit then
        tpButton.BackgroundColor3 = Color3.fromRGB(65, 165, 65)
        local time = minDistance / 200
        local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local targetCFrame = CFrame.new(nearestFruit.Handle.Position)
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetCFrame})
        local connection
        connection = RunService.RenderStepped:Connect(function()
            camera.CFrame = humanoidRootPart.CFrame
        end)
        tween.Completed:Connect(function()
            connection:Disconnect()
            tpButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        end)
        tween:Play()
    end
end

-- TP Button
tpButton = Instance.new("TextButton")
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

-- Auto Store Toggle Button
local autoStoreButton = tpButton:Clone()
autoStoreButton.Position = UDim2.new(0.84, 0, 0.01, 0)
autoStoreButton.Text = autoStoreEnabled and "Auto Store: ON" or "Auto Store: OFF"
autoStoreButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
autoStoreButton.Parent = screenGui
autoStoreButton.MouseButton1Click:Connect(function()
    autoStoreEnabled = not autoStoreEnabled
    autoStoreButton.Text = autoStoreEnabled and "Auto Store: ON" or "Auto Store: OFF"
    saveSettings()
end)

-- ESP Toggle Button
local espButton = tpButton:Clone()
espButton.Position = UDim2.new(0.73, 0, 0.01, 0)
espButton.Text = espEnabled and "ESP: ON" or "ESP: OFF"
espButton.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
espButton.Parent = screenGui
espButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espButton.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    saveSettings()
end)

-- Placeholder Button
local placeholderButton = tpButton:Clone()
placeholderButton.Position = UDim2.new(0.62, 0, 0.01, 0)
placeholderButton.Text = "Placeholder"
placeholderButton.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
placeholderButton.Parent = screenGui
