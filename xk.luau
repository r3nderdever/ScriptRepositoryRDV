local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Function to create the black squircle button
local function createButton()
    local part = Instance.new("Part")
    part.Size = Vector3.new(4, 1, 4)
    part.Shape = Enum.PartType.Cylinder -- Makes it a squircle-like button
    part.Material = Enum.Material.SmoothPlastic
    part.Color = Color3.fromRGB(0, 0, 0) -- Black color
    part.Transparency = 0
    part.Position = Vector3.new(0, 1, 0) -- Adjust position as needed
    part.Anchored = true
    part.CanCollide = false
    part.Parent = workspace

    return part
end

local button = createButton()

-- Function to create a fading black clone
local function createGhostClone(character)
    local clone = character:Clone()
    clone.Parent = workspace

    -- Make the clone black and transparent
    for _, obj in ipairs(clone:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Color = Color3.fromRGB(0, 0, 0) -- Black
            obj.Transparency = 0.3 -- Semi-transparent
            obj.CanCollide = false
        elseif obj:IsA("Humanoid") then
            obj.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        end
    end

    -- Fade the clone out
    local fadeTween = TweenService:Create(
        clone,
        TweenInfo.new(1, Enum.EasingStyle.Linear), -- 1-second fade
        {Transparency = 1}
    )
    fadeTween:Play()
    
    -- Destroy the clone after 1 second
    task.delay(1, function()
        clone:Destroy()
    end)
end

-- Function to teleport the player
local function teleportPlayer()
    if not character then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    -- Save original position and create the clone
    local originalPosition = rootPart.Position
    createGhostClone(character)

    -- Calculate new teleport position (randomly between -35 to 35 studs)
    local randomDistance = math.random(-35, 35)
    local newPosition = originalPosition + Vector3.new(randomDistance, 0, 0)

    -- Teleport the player
    rootPart.Position = newPosition
end

-- Detect user touches on the button
button.Touched:Connect(function(hit)
    local playerTouched = Players:GetPlayerFromCharacter(hit.Parent)
    if playerTouched and playerTouched == player then
        teleportPlayer()
    end
end)
