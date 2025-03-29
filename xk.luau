--// Enhanced teleportation script with shadow clones and random direction

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Ensure we get the player's character safely
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
local uicorner = Instance.new("UICorner")
uicorner.CornerRadius = UDim.new(0.3, 0)
uicorner.Parent = button

-- White outline
local outline = Instance.new("UIStroke")
outline.Thickness = 2
outline.Color = Color3.fromRGB(255, 255, 255)
outline.Parent = button

-- Glow effect
local glow = Instance.new("ImageLabel")
glow.Size = UDim2.new(1.6, 0, 1.6, 0)
glow.Position = UDim2.new(-0.3, 0, -0.3, 0)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://4996891970"
glow.ImageColor3 = Color3.fromRGB(255, 255, 255)
glow.ImageTransparency = 0.6
glow.Parent = button

-- Function to create a fading shadow clone
local function createShadowClone(character)
    local clone = character:Clone()
    clone.Parent = workspace
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

    -- Fade out effect
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    for _, obj in ipairs(clone:GetDescendants()) do
        if obj:IsA("BasePart") then
            local tween = TweenService:Create(obj, tweenInfo, { Transparency = 1 })
            tween:Play()
        end
    end

    -- Destroy clone after tween ends
    task.delay(1, function()
        if clone then
            clone:Destroy()
        end
    end)
end

-- Function to smoothly transition the camera
local function smoothCameraTransition(targetPosition)
    local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local newCFrame = CFrame.lookAt(camera.CFrame.Position, targetPosition)
    local tween = TweenService:Create(camera, tweenInfo, { CFrame = newCFrame })
    tween:Play()
end

-- Function to teleport the player randomly between left and right
local function teleportPlayer()
    local char = getCharacter()
    local hrp = char:FindFirstChild("HumanoidRootPart")

    if hrp then
        -- Randomly pick a teleport distance between -20 (left) and 20 (right)
        local randomOffset = math.random(-20, 20)
        local targetCFrame = hrp.CFrame * CFrame.new(randomOffset, 0, 0)

        -- Ensure target position is safe using raycasting
        local rayOrigin = hrp.Position
        local rayDirection = Vector3.new(randomOffset, 0, 0)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {char}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

        local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

        if not raycastResult then -- No obstacle in the way
            -- Create shadow clone before teleporting
            task.spawn(createShadowClone, char)

            -- Teleport instantly
            hrp.CFrame = targetCFrame

            -- Smooth camera transition
            smoothCameraTransition(hrp.Position)
        else
            warn("Teleport blocked by an obstacle.")
        end
    end
end

-- Connect button click to teleport function
button.MouseButton1Click:Connect(teleportPlayer)
