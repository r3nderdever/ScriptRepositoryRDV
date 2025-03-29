repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")

local plr = Players.LocalPlayer
local placeId = game.PlaceId

-- **🔵 Ensure Player Joins Marines**
local function JoinMarines()
    while plr.Team ~= game.Teams.Marines do
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("SetTeam", "Marines")
        task.wait(1)
    end
end
task.spawn(JoinMarines)

-- **🔥 UI Creation Function**
local function CreateUI()
    local ui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local frame = Instance.new("Frame", ui)
    local title = Instance.new("TextLabel", frame)
    local fruitLabel = Instance.new("TextLabel", frame)
    local statusLabel = Instance.new("TextLabel", frame)
    local credit = Instance.new("TextLabel", frame)
    local gradientFrame = Instance.new("Frame", frame)
    local uiGradient = Instance.new("UIGradient", gradientFrame)

    -- **🎨 UI Styling 🎨**
    frame.Size = UDim2.new(0, 350, 0, 220)
    frame.Position = UDim2.new(0.7, -175, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Black Background
    frame.BorderSizePixel = 0

    -- Gradient Outline Frame
    gradientFrame.Size = UDim2.new(1, 8, 1, 8)
    gradientFrame.Position = UDim2.new(0, -4, 0, -4)
    gradientFrame.BackgroundTransparency = 1

    -- **🔥 Animated Gradient Effect 🔥**
    uiGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 30)), -- Red
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 120, 0))  -- Orange
    }
    uiGradient.Rotation = 0

    -- Title
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "🔥 Fruit Detector UI"
    title.TextSize = 20
    title.TextColor3 = Color3.fromRGB(255, 255, 255)

    -- Fruit Label
    fruitLabel.Size = UDim2.new(1, -10, 0, 50)
    fruitLabel.Position = UDim2.new(0, 5, 0, 40)
    fruitLabel.Text = "🍏 Fruit Name: ???\n📍 Fruit Distance: ???"
    fruitLabel.Font = Enum.Font.Gotham
    fruitLabel.TextSize = 18
    fruitLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    fruitLabel.BackgroundTransparency = 1

    -- Status Label
    statusLabel.Size = UDim2.new(1, -10, 0, 30)
    statusLabel.Position = UDim2.new(0, 5, 0, 100)
    statusLabel.Text = "🔍 Scanning for Fruits..."
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 18
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    statusLabel.BackgroundTransparency = 1

    -- Credit Label
    credit.Size = UDim2.new(1, 0, 0, 20)
    credit.Position = UDim2.new(0, 0, 1, -20)
    credit.Text = "Made by R3nderDV. On Discord"
    credit.Font = Enum.Font.GothamBold
    credit.TextSize = 14
    credit.TextColor3 = Color3.fromRGB(255, 255, 0)
    credit.BackgroundTransparency = 1

    -- Rounded Corners
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 15)

    -- **🎮 Draggable UI**
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function updateInput(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateInput(input)
        end
    end)

    -- **🔥 Animated Gradient Effect 🔥**
    task.spawn(function()
        while true do
            TweenService:Create(uiGradient, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Rotation = 180}):Play()
            task.wait(2)
            TweenService:Create(uiGradient, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Rotation = 0}):Play()
            task.wait(2)
        end
    end)

    return frame, fruitLabel, statusLabel
end

-- **🍏 Fruit Detection System**
local function DetectFruits(fruitLabel, statusLabel)
    while task.wait(1) do
        local closestFruit = nil
        local closestDistance = math.huge

        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Tool") and v.Name:lower():find("fruit") then
                local fruitPos = v:FindFirstChild("Handle") and v.Handle.Position
                if fruitPos then
                    local distance = (plr.Character.HumanoidRootPart.Position - fruitPos).magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestFruit = v
                    end
                end
            end
        end

        if closestFruit then
            fruitLabel.Text = "🍏 Fruit Name: " .. closestFruit.Name .. "\n📍 Fruit Distance: " .. math.floor(closestDistance) .. "m"
            statusLabel.Text = "✅ Fruit Found!"
        else
            fruitLabel.Text = "🍏 Fruit Name: ???\n📍 Fruit Distance: ???"
            statusLabel.Text = "🔍 Scanning for Fruits..."
        end
    end
end

-- **🔄 Server Hop Function**
local function ServerHop(statusLabel)
    statusLabel.Text = "🌍 Server Hopping..."
    task.wait(2) 
    TeleportService:Teleport(placeId)
end

-- **🚀 Run UI & Fruit Detection**
local function MainLoop()
    local frame, fruitLabel, statusLabel = CreateUI()
    
    task.spawn(function()
        DetectFruits(fruitLabel, statusLabel)
    end)

    -- Simulating Server Hop for Testing
    task.delay(60, function() 
        ServerHop(statusLabel) 
    end)
end

task.spawn(MainLoop)
