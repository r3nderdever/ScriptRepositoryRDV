--// mostly stuff for fun, mostly used for tsb.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Ensure we get the player's character
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Create teleport button
local button = Instance.new("TextButton")
button.Parent = screenGui
button.Size = UDim2.new(0, 80, 0, 80)
button.Position = UDim2.new(1, -100, 0.5, -40) -- Right side
button.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Black button
button.Text = ""
button.BorderSizePixel = 0
button.AutoButtonColor = false

-- Rounded corners
local uicorner = Instance.new("UICorner", button)
uicorner.CornerRadius = UDim.new(0.3, 0)

-- White outline
local outline = Instance.new("UIStroke", button)
outline.Thickness = 2
outline.Color = Color3.fromRGB(255, 255, 255)

-- Glow effect
local glow = Instance.new("ImageLabel", button)
glow.Size = UDim2.new(1.6, 0, 1.6, 0)
glow.Position = UDim2.new(-0.3, 0, -0.3, 0)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://4996891970"
glow.ImageColor3 = Color3.fromRGB(255, 255, 255)
glow.ImageTransparency = 0.7

-- Function to create a fading shadow clone
local function createShadowClone(character)
    local clone = character:Clone()
    clone.Parent = game.Workspace
    clone.Name = "ShadowClone"
    
    -- Modify clone appearance
    for _, obj in ipairs(clone:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Color = Color3.new(0, 0, 0) -- Black
            obj.Transparency = 0.3
            obj.Anchored = true -- Prevent falling
            obj.CanCollide = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj:Destroy() -- Remove textures
        elseif obj:IsA("Script") then
            obj:Destroy() -- Remove scripts to avoid conflicts
        end
    end

    -- Fade out over 1 second
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    for _, obj in ipairs(clone:GetDescendants()) do
        if obj:IsA("BasePart") then
            local tween = TweenService:Create(obj, tweenInfo, { Transparency = 1 })
            tween:Play()
        end
    end

    -- Destroy clone after tween ends
    task.delay(1, function() clone:Destroy() end)
end

-- Function to teleport and smooth camera transition
local function teleportPlayer()
    local char = getCharacter()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local camera = game.Workspace.CurrentCamera

    if hrp and camera then
        local originalCFrame = hrp.CFrame
        local targetCFrame = originalCFrame * CFrame.new(20, 0, 0)

        -- Create shadow clone before teleporting
        task.spawn(createShadowClone, char)

        -- Teleport instantly
        hrp.CFrame = targetCFrame

        -- Smooth camera transition
        local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(camera, tweenInfo, { CFrame = CFrame.lookAt(camera.CFrame.Position, hrp.Position) })
        tween:Play()
    end
end

-- Connect button click to teleport function
button.MouseButton1Click:Connect(teleportPlayer)
