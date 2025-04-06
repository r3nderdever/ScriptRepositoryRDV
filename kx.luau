-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- Player
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local camera = Workspace.CurrentCamera

-- Save file
local saveFile = "RDVfruitNotifier201.json"
local savedSettings = {
    ESP = false,
    AutoStore = false,
}

if isfile(saveFile) then
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(saveFile))
    end)
    if success and typeof(data) == "table" then
        savedSettings = data
    end
end

local function saveSettings()
    writefile(saveFile, HttpService:JSONEncode(savedSettings))
end

-- UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local function createButtonEffect(button)
    local ring = Instance.new("Frame")
    ring.Size = button.Size
    ring.Position = UDim2.new(0, 0, 0, 0)
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.Position = UDim2.new(0.5, 0, 0.5, 0)
    ring.BackgroundColor3 = button.BackgroundColor3
    ring.BackgroundTransparency = 0.5
    ring.BorderSizePixel = 0
    ring.ZIndex = 0
    ring.Parent = button

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ring

    local tweenOut = TweenService:Create(ring, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(1.5, 0, 1.5, 0),
        BackgroundTransparency = 1
    })
    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        ring:Destroy()
    end)
end

local function createStyledButton(text, pos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.1, 0, 0.08, 0)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        createButtonEffect(btn)
    end)

    return btn
end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.3, 0, 0.08, 0)
frame.Position = UDim2.new(0.5, 0, 0.01, 0)
frame.AnchorPoint = Vector2.new(0.5, 0)
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

-- Fruit List
local fruitsList = {
    "Fruit ", "Rocket Fruit", "Spin Fruit", "Ghost Fruit", "Spring Fruit", "Bomb Fruit", "Spike Fruit", "Smoke Fruit", "Blade Fruit",
    "Sand Fruit", "Ice Fruit", "Dark Fruit", "Diamond Fruit", "Light Fruit", "Rubber Fruit", "Barrier Fruit", "Magma Fruit", "Phoenix Fruit",
    "Love Fruit", "Spider Fruit", "Sound Fruit", "Buddha Fruit", "Quake Fruit", "Gravity Fruit", "Control Fruit", "T-Rex Fruit",
    "Mammoth Fruit", "Spirit Fruit", "Venom Fruit", "Shadow Fruit", "Rumble Fruit", "Portal Fruit", "Blizzard Fruit", "Dragon Fruit",
    "Leopard Fruit", "Dough Fruit", "Dragon (West) Fruit", "Dragon (East) Fruit", "Kitsune Fruit", "Gas Fruit", "Flame Fruit", "Yeti Fruit"
}

-- Find nearest fruit
local function findNearestFruit()
    local nearest, minDist, count = nil, math.huge, 0
    for _, fruit in ipairs(Workspace:GetChildren()) do
        if table.find(fruitsList, fruit.Name) and fruit:FindFirstChild("Handle") then
            local dist = (humanoidRootPart.Position - fruit.Handle.Position).Magnitude
            count += 1
            if dist < minDist then
                minDist = dist
                nearest = fruit
            end
        end
    end
    return nearest, minDist, count
end

-- Fruit ESP
local activeBillboards = {}
local function createBillboard(fruit)
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 100, 0, 30)
    bb.Adornee = fruit:FindFirstChild("Handle")
    bb.AlwaysOnTop = true
    bb.Parent = fruit

    local label = Instance.new("TextLabel")
    label.Text = fruit.Name
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 0)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = bb
    return bb
end

local function updateESP()
    for _, gui in pairs(activeBillboards) do
        if gui and gui.Parent then gui:Destroy() end
    end
    table.clear(activeBillboards)
    if savedSettings.ESP then
        for _, fruit in ipairs(Workspace:GetChildren()) do
            if table.find(fruitsList, fruit.Name) and fruit:FindFirstChild("Handle") then
                table.insert(activeBillboards, createBillboard(fruit))
            end
        end
    end
end

task.spawn(function()
    while true do
        if savedSettings.ESP then updateESP() end
        task.wait(1)
    end
end)

-- Fruit Label UI Update
spawn(function()
    while true do
        local nearest, distance, count = findNearestFruit()
        if nearest then
            fruitLabel.Text = "🍌 Nearest: " .. nearest.Name .. " | 🚩 Distance: " .. math.floor(distance) .. "⚡ Total Fruits: " .. count
        else
            fruitLabel.Text = "No fruits found in server 🚩"
        end
        task.wait(0.05)
    end
end)

-- Auto Store
local function autoStore()
    if not savedSettings.AutoStore then return end
    local backpack = player:WaitForChild("Backpack")
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:find("Fruit") then
            local original = tool:GetAttribute("OriginalName") or tool.Name
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", original, tool)
        end
    end
end

task.spawn(function()
    while true do
        autoStore()
        task.wait(3)
    end
end)

-- Buttons and Positioning
local leftButton1 = createStyledButton("TP", UDim2.new(0.1, 0, 0.01, 0), Color3.fromRGB(255, 100, 100))
local leftButton2 = createStyledButton("Placeholder", UDim2.new(0.225, 0, 0.01, 0), Color3.fromRGB(140, 140, 140))
local rightButton1 = createStyledButton("AutoStore: " .. (savedSettings.AutoStore and "On" or "Off"), UDim2.new(0.675, 0, 0.01, 0), Color3.fromRGB(100, 150, 255))
local rightButton2 = createStyledButton("ESP: " .. (savedSettings.ESP and "On" or "Off"), UDim2.new(0.8, 0, 0.01, 0), Color3.fromRGB(100, 255, 100))

-- Button Logic
leftButton1.MouseButton1Click:Connect(function()
    local fruit, dist = findNearestFruit()
    if fruit then
        local tweenTime = dist / 200
        leftButton1.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        local tween = TweenService:Create(humanoidRootPart, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = CFrame.new(fruit.Handle.Position)})
        local camConn = RunService.RenderStepped:Connect(function()
            camera.CFrame = humanoidRootPart.CFrame
        end)
        tween.Completed:Connect(function()
            camConn:Disconnect()
            leftButton1.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        end)
        tween:Play()
    end
end)

rightButton1.MouseButton1Click:Connect(function()
    savedSettings.AutoStore = not savedSettings.AutoStore
    rightButton1.Text = "AutoStore: " .. (savedSettings.AutoStore and "On" or "Off")
    saveSettings()
end)

rightButton2.MouseButton1Click:Connect(function()
    savedSettings.ESP = not savedSettings.ESP
    rightButton2.Text = "ESP: " .. (savedSettings.ESP and "On" or "Off")
    saveSettings()
    updateESP()
end)

-- Webhook Setup
local webhook = "https://discord.com/api/webhooks/1355686213662802110/Zb2ToOaLRgzBq33aMO3Z4pAEId-d68akqQwwKQagx092AziDLneZYTgw9rOsHRbWdWTi"
local sentFruits = {}

local function sendWebhook(fruitName, distance)
    local body = HttpService:JSONEncode({
        content = "",
        embeds = {{
            title = "Fruit Found!",
            description = "**" .. fruitName .. "** detected\nDistance: `" .. math.floor(distance) .. "` studs",
            color = 0xeba300
        }}
    })

    task.spawn(function()
        (syn and syn.request or fluxus and fluxus.request or fluxus_request or http and http.request or http_request)({
            Url = webhook,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = body
        })
    end)
end

-- Fruit Detection + Notification
task.spawn(function()
    while true do
        local nearest, distance, _ = findNearestFruit()
        if nearest and nearest:FindFirstChild("Handle") then
            local key = nearest.Name .. tostring(nearest.Handle.Position)
            if not sentFruits[key] then
                sentFruits[key] = true
                sendWebhook(nearest.Name, distance)
            end
        end
        task.wait(1)
    end
end)
