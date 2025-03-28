local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local plr = Players.LocalPlayer

local timer = 0
local Config = {
    AutoStoreFruit = true,
}

local fruitsList = {
    "Fruit ", "Rocket Fruit", "Spin Fruit", "Chop Fruit", "Spring Fruit", "Bomb Fruit", "Spike Fruit",
    "Smoke Fruit", "Blade Fruit", "Sand Fruit", "Ice Fruit", "Dark Fruit", "Diamond Fruit", "Light Fruit",
    "Rubber Fruit", "Barrier Fruit", "Magma Fruit", "Phoenix Fruit", "Love Fruit", "Spider Fruit",
    "Sound Fruit", "Buddha Fruit", "Quake Fruit", "Gravity Fruit", "Control Fruit", "T-Rex Fruit",
    "Mammoth Fruit", "Spirit Fruit", "Venom Fruit", "Shadow Fruit", "Rumble Fruit", "Portal Fruit",
    "Blizzard Fruit", "Dragon Fruit", "Leopard Fruit", "Dough Fruit", "Dragon (West) Fruit",
    "Dragon (East) Fruit", "Kitsune Fruit", "Gas Fruit", "Yeti Fruit"
}

-- Ensure the player joins the correct team
local function JoinTeam()
    task.wait(2)  -- Wait a bit before joining the team to ensure the player is loaded
    if plr.Team ~= game.Teams.Marines and plr.Team ~= game.Teams.Pirates then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Marines")
    end
end

-- Automatically store any fruits found
local function HandleAutoStore(tool)
    if Config.AutoStoreFruit and tool:IsA("Tool") and tool.Name:find("Fruit") then
        task.spawn(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", tool:GetAttribute("OriginalName"), tool)
        end)
    end
end

local function AutoStoreLoop()
    while true do
        for _, tool in ipairs(plr.Backpack:GetChildren()) do
            HandleAutoStore(tool)
        end
        task.wait(0.5)
    end
end

-- Finds the nearest fruit
local function GetNearestFruit()
    local nearestFruit = nil
    local nearestDistance = math.huge
    for _, fruitName in ipairs(fruitsList) do
        local fruit = Workspace:FindFirstChild(fruitName)
        if fruit and fruit:FindFirstChild("Handle") then
            local distance = (plr.Character.HumanoidRootPart.Position - fruit.Handle.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestFruit = fruit
            end
        end
    end
    return nearestFruit, nearestDistance
end

-- Create a UI for the player, which includes the text display and snake animation
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local Background = Instance.new("Frame", ScreenGui)
    Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Background.Size = UDim2.new(1, 0, 1, 0)  -- Full screen, non-transparent

    local TopText = Instance.new("TextLabel", Background)
    TopText.Size = UDim2.new(1, 0, 0, 50)
    TopText.Position = UDim2.new(0, 0, 0, 0)
    TopText.BackgroundTransparency = 1
    TopText.Text = "Made By R3nderDV. On Discord."
    TopText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TopText.TextScaled = true
    TopText.Font = Enum.Font.ComicSans

    local FruitText = Instance.new("TextLabel", Background)
    FruitText.Size = UDim2.new(1, 0, 0, 50)
    FruitText.Position = UDim2.new(0, 0, 0.8, 0)
    FruitText.BackgroundTransparency = 1
    FruitText.Text = "Fruit: Searching... | Distance: N/A"
    FruitText.TextColor3 = Color3.fromRGB(255, 255, 255)
    FruitText.TextScaled = true
    FruitText.Font = Enum.Font.ComicSans

    local SnakeText = Instance.new("TextLabel", Background)
    SnakeText.Size = UDim2.new(1, 0, 0, 50)
    SnakeText.Position = UDim2.new(0, 0, 0.4, 0)
    SnakeText.BackgroundTransparency = 1
    SnakeText.Text = "......"
    SnakeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    SnakeText.TextScaled = true
    SnakeText.Font = Enum.Font.ComicSans

    return FruitText, SnakeText
end

-- Smoothly move the player to the fruit with easing
local function TeleportToFruit()
    local label, snakeText = CreateUI()
    local hrp = plr.Character:WaitForChild("HumanoidRootPart")
    local camera = game.Workspace.CurrentCamera

    while true do
        local nearestFruit, distance = GetNearestFruit()
        
        if nearestFruit then
            local fruitPosition = nearestFruit.Handle.Position
            local direction = (fruitPosition - hrp.Position).unit
            local moveSpeed = math.random(190, 200)
            local travelTime = distance / moveSpeed

            -- Smooth Camera Move to Fruit
            local cameraGoal = { CFrame = CFrame.new(fruitPosition) }
            local cameraTween = TweenService:Create(camera, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), cameraGoal)
            cameraTween:Play()

            -- Update Text
            label.Text = "Fruit: " .. nearestFruit.Name .. " | Distance: " .. math.floor(distance) .. " studs"
            task.wait(travelTime)
        else
            label.Text = "No fruit found"
        end
        
        task.wait(0.04) -- Update the text every 0.04 seconds
    end
end

-- Ensures the script restarts when the player respawns
plr.CharacterAdded:Connect(function()
    task.wait(1) -- Wait for Character to Load
    JoinTeam()
    task.spawn(TeleportToFruit)
end)

-- Start everything
task.spawn(JoinTeam)
task.spawn(AutoStoreLoop)
task.spawn(TeleportToFruit)
