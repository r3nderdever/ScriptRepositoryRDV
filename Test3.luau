repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local plr = Players.LocalPlayer
local placeId = game.PlaceId

-- **🔵 Auto Join Marines**
local function JoinMarines()
    while plr.Team ~= game.Teams.Marines do
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("SetTeam", "Marines")
        task.wait(1)
    end
end
task.spawn(JoinMarines)

-- **🔥 Create UI**
local function CreateUI()
    local ui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local frame = Instance.new("Frame", ui)
    local gradientOutline = Instance.new("Frame", frame)
    local glowEffect = Instance.new("ImageLabel", frame)
    local uiGradient = Instance.new("UIGradient", gradientOutline)
    local title = Instance.new("TextLabel", frame)
    local fruitLabel = Instance.new("TextLabel", frame)
    local statusLabel = Instance.new("TextLabel", frame)
    local credit = Instance.new("TextLabel", frame)

    -- **🎨 Main Frame**
    frame.Size = UDim2.new(0, 350, 0, 220)
    frame.Position = UDim2.new(0.7, -175, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Black
    frame.BorderSizePixel = 0
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 10)

    -- **🔥 Gradient Outline**
    gradientOutline.Size = UDim2.new(1, 10, 1, 10)
    gradientOutline.Position = UDim2.new(0, -5, 0, -5)
    gradientOutline.BackgroundTransparency = 0.5

    -- **🔥 Gradient Effect**
    uiGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 30)), -- Red
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 120, 0))  -- Orange
    }
    uiGradient.Rotation = 0

    -- **✨ Glow Effect**
    glowEffect.Size = UDim2.new(1, 20, 1, 20)
    glowEffect.Position = UDim2.new(0, -10, 0, -10)
    glowEffect.BackgroundTransparency = 1
    glowEffect.Image = "rbxassetid://4996891970"
    glowEffect.ImageColor3 = Color3.fromRGB(255, 80, 30)
    glowEffect.ImageTransparency = 0.3

    -- **🔥 Gradient Animation**
    task.spawn(function()
        while true do
            TweenService:Create(uiGradient, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Rotation = 180}):Play()
            task.wait(2)
            TweenService:Create(uiGradient, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Rotation = 0}):Play()
            task.wait(2)
        end
    end)

    -- **📢 UI Text**
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "🔥 Fruit Detector UI"
    title.TextSize = 20
    title.TextColor3 = Color3.fromRGB(255, 255, 255)

    fruitLabel.Size = UDim2.new(1, -10, 0, 50)
    fruitLabel.Position = UDim2.new(0, 5, 0, 40)
    fruitLabel.Text = "🍏 Fruit Name: ???\n📍 Fruit Distance: ???"
    fruitLabel.Font = Enum.Font.Gotham
    fruitLabel.TextSize = 18
    fruitLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    fruitLabel.BackgroundTransparency = 1

    statusLabel.Size = UDim2.new(1, -10, 0, 30)
    statusLabel.Position = UDim2.new(0, 5, 0, 100)
    statusLabel.Text = "🔍 Scanning for Fruits..."
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 18
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    statusLabel.BackgroundTransparency = 1

    credit.Size = UDim2.new(1, 0, 0, 20)
    credit.Position = UDim2.new(0, 0, 1, -20)
    credit.Text = "Made by R3nderDV. On Discord"
    credit.Font = Enum.Font.GothamBold
    credit.TextSize = 14
    credit.TextColor3 = Color3.fromRGB(255, 255, 0)
    credit.BackgroundTransparency = 1

    return frame, fruitLabel, statusLabel
end

-- **🍏 Detect Fruits**
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

-- **🔄 Server Hop**
local function ServerHop(statusLabel)
    statusLabel.Text = "🌍 Server Hopping..."
    task.wait(2) 
    TeleportService:Teleport(placeId)
end

-- **🚀 Run Everything**
local function MainLoop()
    local frame, fruitLabel, statusLabel = CreateUI()
    
    task.spawn(function()
        DetectFruits(fruitLabel, statusLabel)
    end)

    -- **Auto Server Hop After 60s**
    task.delay(60, function() 
        ServerHop(statusLabel) 
    end)
end

task.spawn(MainLoop)
