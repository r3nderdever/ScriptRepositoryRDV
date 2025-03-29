local Players = game:GetService("Players")
local player = Players.LocalPlayer

local character = script.Parent
local humanoid = character:FindFirstChildOfClass("Humanoid")
local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

if not humanoid or not humanoidRootPart then return end

local ragdollJoints = {}

-- Function to create BallSocketConstraints for smooth ragdoll physics
local function setupRagdoll()
    for _, joint in ipairs(character:GetDescendants()) do
        if joint:IsA("Motor6D") then
            local part0, part1 = joint.Part0, joint.Part1
            if part0 and part1 then
                -- Create a BallSocketConstraint to replace the Motor6D
                local attachment0 = Instance.new("Attachment", part0)
                attachment0.Position = joint.C0.Position
                
                local attachment1 = Instance.new("Attachment", part1)
                attachment1.Position = joint.C1.Position

                local ballSocket = Instance.new("BallSocketConstraint")
                ballSocket.Attachment0 = attachment0
                ballSocket.Attachment1 = attachment1
                ballSocket.Parent = part1
                
                -- Store original joint for later restoration
                ragdollJoints[part1] = { joint, ballSocket }
                
                -- Disable the Motor6D
                joint.Enabled = false
            end
        end
    end
end

-- Function to enable ragdoll
local function enableRagdoll()
    setupRagdoll() -- Replace Motor6Ds with physics joints
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Anchored = false -- Fully unanchor the character
        end
    end
    humanoid.PlatformStand = true -- Disable movement controls
end

-- Function to disable ragdoll and restore joints
local function disableRagdoll()
    for part, data in pairs(ragdollJoints) do
        local originalJoint, ballSocket = data[1], data[2]
        if ballSocket then ballSocket:Destroy() end -- Remove physics joint
        if originalJoint then originalJoint.Enabled = true end -- Re-enable original joint
    end
    humanoid.PlatformStand = false -- Restore movement
    ragdollJoints = {} -- Clear stored joints
end

-- Health Change Event
local lastHealth = humanoid.Health
humanoid.HealthChanged:Connect(function(newHealth)
    if newHealth < lastHealth then -- Only trigger when damaged
        enableRagdoll() -- Make player fall over smoothly
        task.wait(2) -- Wait for 2 seconds
        disableRagdoll() -- Restore character control
    end
    lastHealth = newHealth -- Update health tracker
end)
