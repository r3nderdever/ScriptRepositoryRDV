local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humRoot = char:WaitForChild("HumanoidRootPart")

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Function to create buttons
local function createButton(text, pos, size)
    local button = Instance.new("TextButton")
    button.Parent = screenGui
    button.Size = size
    button.Position = pos
    button.Text = text
    button.BackgroundColor3 = Color3.new(0, 0, 0)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BorderSizePixel = 0
    button.BackgroundTransparency = 0.2
    button.Font = Enum.Font.SourceSansBold
    button.TextScaled = true
    button.AutoButtonColor = true
    button.ClipsDescendants = true
    button.CornerRadius = UDim.new(0, 20)
    
    return button
end

local mainButton = createButton("Teleport", UDim2.new(0.4, 0, 0.8, 0), UDim2.new(0.15, 0, 0.1, 0))
local fastButton = createButton("Flash Move", UDim2.new(0.56, 0, 0.8, 0), UDim2.new(0.1, 0, 0.1, 0))

-- Function to create a fading shadow clone
local function createShadowClone()
    local clone = char:Clone()
    clone.Parent = workspace
    clone.Name = "ShadowClone"

    for _, part in pairs(clone:GetChildren()) do
        if part:IsA("BasePart") then
            part.Transparency = 0.5
            part.Material = Enum.Material.SmoothPlastic
        end
    end

    -- Tween to fade out
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    for _, part in pairs(clone:GetChildren()) do
        if part:IsA("BasePart") then
            local tween = TweenService:Create(part, tweenInfo, {Transparency = 1})
            tween:Play()
        end
    end

    -- Remove clone after 2 seconds
    game:GetService("Debris"):AddItem(clone, 2)
end

-- Function to teleport in a circle
local function circleTeleport()
    local angle = math.rad(math.random(0, 360))
    local newX = humRoot.Position.X + math.cos(angle) * 24
    local newZ = humRoot.Position.Z + math.sin(angle) * 24
    local newPosition = Vector3.new(newX, humRoot.Position.Y, newZ)

    createShadowClone()
    humRoot.CFrame = CFrame.new(newPosition)
end

-- Function for fast left-right teleportation
local function fastTeleport()
    for i = 1, 20 do
        task.wait(0.05)
        createShadowClone()
        local offset = math.random(-20, 20)
        humRoot.CFrame = humRoot.CFrame * CFrame.new(offset, 0, -1.5)
    end
end

mainButton.MouseButton1Click:Connect(circleTeleport)
fastButton.MouseButton1Click:Connect(fastTeleport)
