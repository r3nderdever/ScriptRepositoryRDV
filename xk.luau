local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Ensure we get the player's character
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Function to create a button
local function createButton(size, position, parent)
    local button = Instance.new("TextButton")
    button.Parent = parent
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
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

    return button
end

-- Create main teleport button
local teleportButton = createButton(UDim2.new(0, 80, 0, 80), UDim2.new(1, -100, 0.5, -40), screenGui)

-- Create rapid teleport button
local rapidTeleportButton = createButton(UDim2.new(0, 50, 0, 50), UDim2.new(1, -90, 0.5, 50), screenGui)

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
            obj.Anchored = true
            obj.CanCollide = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj:Destroy()
        elseif obj:IsA("Script") then
            obj:Destroy()
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

-- Function to teleport the player randomly left or right
local function teleportPlayer()
    local char = getCharacter()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local camera = game.Workspace.CurrentCamera

    if hrp and camera then
        local originalCFrame = hrp.CFrame
        local direction = math.random(0, 1) == 0 and -20 or 20 -- Randomly pick left (-20) or right (+20)
        local targetCFrame = originalCFrame * CFrame.new(direction, 0, 0)
        local lockedCameraCFrame = camera.CFrame -- Save the locked camera position

        -- 1. Lock the camera in place instantly
        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = lockedCameraCFrame

        -- 2. Delay 0.03 seconds before teleporting the player
        task.delay(0.03, function()
            createShadowClone(char)
            hrp.CFrame = targetCFrame
        end)

        -- 3. Delay 0.04 seconds (after teleport) before tweening the camera smoothly back
        task.delay(0.07, function()
            local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(camera, tweenInfo, { CFrame = CFrame.lookAt(camera.CFrame.Position, hrp.Position) })
            tween:Play()

            tween.Completed:Connect(function()
                camera.CameraType = Enum.CameraType.Custom
            end)
        end)
    end
end

-- Function for rapid teleporting 14 times over 1.3 seconds (random left/right)
local function rapidTeleport()
    local char = getCharacter()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local camera = game.Workspace.CurrentCamera

    if hrp and camera then
        local lockedCameraCFrame = camera.CFrame
        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = lockedCameraCFrame

        for i = 1, 14 do
            task.delay((i - 1) * (1.3 / 14), function()
                if hrp then
                    local randomOffset = math.random(-20, 20) -- Random movement between -20 and +20
                    hrp.CFrame = hrp.CFrame * CFrame.new(randomOffset, 0, -4) -- Move forward 4 studs
                    createShadowClone(char)
                end
            end)
        end

        -- Tween camera back to player after 1.3 seconds
        task.delay(1.3, function()
            local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(camera, tweenInfo, { CFrame = CFrame.lookAt(camera.CFrame.Position, hrp.Position) })
            tween:Play()

            tween.Completed:Connect(function()
                camera.CameraType = Enum.CameraType.Custom
            end)
        end)
    end
end

-- Connect buttons
teleportButton.MouseButton1Click:Connect(teleportPlayer)
rapidTeleportButton.MouseButton1Click:Connect(rapidTeleport)
