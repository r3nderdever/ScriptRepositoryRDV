local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local TELEPORT_RADIUS = 18
local DETECTION_RADIUS = 16
local FADE_TIME = 2

-- Function to get all nearby players
local function getNearbyPlayers()
    local nearby = {}
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            if otherRoot then
                local distance = (otherRoot.Position - root.Position).Magnitude
                if distance <= DETECTION_RADIUS then
                    table.insert(nearby, otherPlayer)
                end
            end
        end
    end
    return nearby
end

-- Function to generate a random teleport position
local function getRandomPositionAround(center, radius)
    local angle = math.rad(math.random(0, 360))
    local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
    return center + offset
end

-- Function to create and fade out a clone
local function createClone()
    local clone = character:Clone()
    clone.Parent = workspace

    -- Remove scripts inside the clone to prevent issues
    for _, obj in pairs(clone:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            obj:Destroy()
        end
    end

    local cloneRoot = clone:FindFirstChild("HumanoidRootPart")
    if cloneRoot then
        cloneRoot.Anchored = true
        cloneRoot.CFrame = root.CFrame
    end

    -- Fade out effect
    local startTime = tick()
    local connection
    connection = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - startTime
        local alpha = math.clamp(elapsed / FADE_TIME, 0, 1)
        
        for _, part in pairs(clone:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = alpha
            end
        end

        if alpha >= 1 then
            connection:Disconnect()  -- Disconnect after fading is complete
            clone:Destroy()
        end
    end)
end

-- Function to teleport the player to a random location while maintaining their facing direction
local function teleportAndFaceDirection()
    -- Store the player's current facing direction (orientation)
    local currentOrientation = root.CFrame - root.Position
    
    -- Teleport the player to a random location
    local teleportPosition = getRandomPositionAround(root.Position, TELEPORT_RADIUS)
    character:SetPrimaryPartCFrame(CFrame.new(teleportPosition))
    
    -- Set the player to face the same direction as before the teleport
    local newCFrame = CFrame.new(teleportPosition) * CFrame.new(currentOrientation.Position)
    root.CFrame = newCFrame
end

-- Main loop to check for nearby players
local function checkForNearbyPlayers()
    while true do
        task.wait(0.05) -- Check every 0.05 seconds
        if #getNearbyPlayers() > 0 then
            -- Teleport player to a random position and make them face the same direction
            teleportAndFaceDirection()
            createClone()  -- Create the clone after teleportation
        end
    end
end

-- Start checking for nearby players in a separate thread
spawn(checkForNearbyPlayers)
