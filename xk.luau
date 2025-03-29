--// Teleportation script with smooth random teleport, shadow clones, and camera transition

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

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
glow.Parent = button

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
    task.delay(1, function()
        clone:Destroy()
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
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if hrp then
        -- Generate a random teleport distance (-20 = left, 20 = right)
        local randomOffset = math.random(-20, 20)

        -- Compute target position
        local targetPosition = hrp.Position + Vector3.new(randomOffset, 0, 0)
        local targetCFrame = CFrame.new(targetPosition)

        -- Raycast to check if teleport is safe
        local rayDirection = Vector3.new(randomOffset, 0, 0)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {char}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

        local raycastResult = workspace:Raycast(hrp.Position, rayDirection, raycastParams)

        -- Attempt teleportation
        if not raycastResult then
            -- Create shadow clone before teleporting
            task.spawn(createShadowClone, char)

            -- Teleport instantly
            hrp.CFrame = targetCFrame

            -- Smooth camera transition
            smoothCameraTransition(hrp.Position)
        else
            warn("Teleport blocked by an obstacle. Trying a different spot...")

            -- Try teleporting again with a different offset
            local secondOffset = math.random(-20, 20)
            local secondTarget = hrp.Position + Vector3.new(secondOffset, 0, 0)
            local secondCFrame = CFrame.new(secondTarget)
            local secondResult = workspace:Raycast(hrp.Position, Vector3.new(secondOffset, 0, 0), raycastParams)

            if not secondResult then
                task.spawn(createShadowClone, char)
                hrp.CFrame = secondCFrame
                smoothCameraTransition(hrp.Position)
            else
                warn("Second teleport attempt also blocked. No valid teleport spots available.")
            end
        end
    end
end

-- Connect button click to teleport function
button.MouseButton1Click:Connect(teleportPlayer)
