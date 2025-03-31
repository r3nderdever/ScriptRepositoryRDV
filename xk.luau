-- ROBLOX EXECUTOR COMPATIBLE FLY SCRIPT
-- Features: Smooth flight, admin toggle, enhanced movement, animations

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChildOfClass("Humanoid")
local root = character:FindFirstChild("HumanoidRootPart")

local FLY_SPEED = 100
local LIFT_FORCE = 6
local DECELERATION = 0.92
local TURN_SPEED = 2
local flying = false
local velocity = Vector3.new(0, 0, 0)

local function stopAllAnimations()
    for _, track in pairs(humanoid.Animator:GetPlayingAnimationTracks()) do
        track:Stop()
    end
end

local function createFlyingAnimation()
    local flyAnim = Instance.new("Animation")
    flyAnim.AnimationId = "rbxassetid://619542203"
    return flyAnim
end

local function setFlyingMode(enable)
    if not root then return end
    flying = enable
    
    if flying then
        stopAllAnimations()
        
        local flyAnim = createFlyingAnimation()
        local flyTrack = humanoid.Animator:LoadAnimation(flyAnim)
        flyTrack.Looped = true
        flyTrack:Play()
        
        local flightConnection
        flightConnection = RunService.RenderStepped:Connect(function()
            if not flying then
                flightConnection:Disconnect()
                return
            end
            
            local moveDirection = humanoid.MoveDirection
            if moveDirection.Magnitude > 0 then
                velocity = moveDirection * FLY_SPEED
            else
                velocity = velocity * DECELERATION
            end
            root.Velocity = velocity + Vector3.new(0, LIFT_FORCE, 0)
        end)
    else
        stopAllAnimations()
        root.Velocity = Vector3.new(0, -5, 0)
    end
end

local function onJumpRequest()
    if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
        setFlyingMode(not flying)
    end
end

UserInputService.JumpRequest:Connect(onJumpRequest)

-- Enhanced: Smooth turning while flying
local function onMove(input, gameProcessed)
    if flying and not gameProcessed then
        local moveDirection = humanoid.MoveDirection
        if moveDirection.Magnitude > 0 then
            root.CFrame = root.CFrame:Lerp(CFrame.lookAt(root.Position, root.Position + moveDirection), TURN_SPEED * RunService.RenderStepped:Wait())
        end
    end
end
UserInputService.InputBegan:Connect(onMove)

-- Admin commands
local function onChatMessage(message)
    if message == "/fly" then
        setFlyingMode(not flying)
    elseif message == "/flyspeedup" then
        FLY_SPEED = FLY_SPEED + 10
    elseif message == "/flyspeeddown" then
        FLY_SPEED = math.max(10, FLY_SPEED - 10)
    elseif message == "/stopfly" then
        flying = false
        setFlyingMode(false)
    end
end

player.Chatted:Connect(onChatMessage)

-- Debug Mode (Optional: Uncomment for real-time logs)
-- RunService.RenderStepped:Connect(function()
--     if flying then
--         print("Flying at speed:", FLY_SPEED)
--     end
-- end)
