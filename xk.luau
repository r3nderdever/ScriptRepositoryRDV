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

-- Function to create a fading shadow clone (with same position & rotation)
local function createShadowClone(position, rotation)
    local char = getCharacter()
    if not char then return end

    local clone = char:Clone()
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
            obj.CFrame = CFrame.new(position) * rotation -- Set clone's exact position & rotation
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
                    -- Save the starting position & rotation
                    local startPosition = hrp.Position
                    local startRotation = hrp.CFrame - hrp.Position

                    -- Create a shadow clone at the current position before teleporting
                    createShadowClone(startPosition, startRotation)

                    -- Generate a random left/right teleport offset (-20 to 20)
                    local randomOffset = math.random(-20, 20)

                    -- Move the player to the new position
                    hrp.CFrame = hrp.CFrame * CFrame.new(randomOffset, 0, -4) -- Move forward 4 studs

                    -- Save new position & rotation
                    local endPosition = hrp.Position
                    local endRotation = hrp.CFrame - hrp.Position

                    -- Create another shadow clone at the new position
                    createShadowClone(endPosition, endRotation)
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
rapidTeleportButton.MouseButton1Click:Connect(rapidTeleport)
