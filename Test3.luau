repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local plr = Players.LocalPlayer

-- Function to make sure player joins Marines on spawn
local function JoinMarines()
    while plr.Team ~= game.Teams.Marines do
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("SetTeam", "Marines")
        task.wait(1)
    end
end
task.spawn(JoinMarines)

-- **🔥 Stunning Orange-Red UI Creation 🔥**
local function CreateUI()
    local ui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local frame = Instance.new("Frame", ui)
    local title = Instance.new("TextLabel", frame)
    local fruitLabel = Instance.new("TextLabel", frame)
    local credit = Instance.new("TextLabel", frame)

    -- **🎨 UI Styling 🎨**
    frame.Size = UDim2.new(0, 350, 0, 200)
    frame.Position = UDim2.new(0.7, -175, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(200, 50, 30) -- 🔥 Orange-Red
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.2

    -- Rounded corners
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 15)

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
    fruitLabel.Text = "🔍 Searching for Fruits..."
    fruitLabel.Font = Enum.Font.Gotham
    fruitLabel.TextSize = 18
    fruitLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    fruitLabel.BackgroundTransparency = 1

    -- Credit Label
    credit.Size = UDim2.new(1, 0, 0, 20)
    credit.Position = UDim2.new(0, 0, 1, -20)
    credit.Text = "Made by R3nderDV. On Discord"
    credit.Font = Enum.Font.GothamBold
    credit.TextSize = 14
    credit.TextColor3 = Color3.fromRGB(255, 255, 0)
    credit.BackgroundTransparency = 1

    -- **Draggable UI**
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

    return frame, fruitLabel
end

-- **🍏 Fruit Detection System**
local function DetectFruits(fruitLabel)
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
            fruitLabel.Text = "🍏 Nearest Fruit: " .. closestFruit.Name .. "\n📍 Distance: " .. math.floor(closestDistance) .. "m"
        else
            fruitLabel.Text = "No Fruits Nearby!"
        end
    end
end

-- **🚀 Run UI & Fruit Detection**
local function MainLoop()
    local frame, fruitLabel = CreateUI()

    task.spawn(function()
        DetectFruits(fruitLabel)
    end)
end

task.spawn(MainLoop)
