local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedNoclipGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 40, 0, 40)
button.Position = UDim2.new(0.5, 0, 0, -50) -- start off-screen
button.AnchorPoint = Vector2.new(0.5, 0)
button.BackgroundColor3 = Color3.fromRGB(255, 179, 186) -- pastel red
button.Text = "↑"
button.TextColor3 = Color3.new(0, 0, 0)
button.TextScaled = true
button.Font = Enum.Font.GothamBlack
button.Name = "ToggleButton"
button.Parent = screenGui
button.BorderSizePixel = 0
button.ClipsDescendants = true
button.AutoButtonColor = false
button.BackgroundTransparency = 0
button.ZIndex = 10
button.TextStrokeTransparency = 0.5
button.TextStrokeColor3 = Color3.new(1, 1, 1)

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = button

-- Slide In Animation
TweenService:Create(button, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
	Position = UDim2.new(0.5, 0, 0, 0)
}):Play()

-- Toggle Logic
local enabled = false
local noclipParts = {}

local function toggleState()
	enabled = not enabled
	if enabled then
		button.BackgroundColor3 = Color3.fromRGB(186, 255, 201) -- pastel green
		button.TextColor3 = Color3.new(1, 1, 1) -- white arrow
	else
		button.BackgroundColor3 = Color3.fromRGB(255, 179, 186) -- pastel red
		button.TextColor3 = Color3.new(0, 0, 0) -- black arrow
		if humanoid then
			humanoid.WalkSpeed = 16
		end
	end
end

button.MouseButton1Click:Connect(toggleState)

-- Main loop
RunService.RenderStepped:Connect(function()
	character = player.Character
	if not character or not character:FindFirstChild("Humanoid") then return end
	humanoid = character:FindFirstChild("Humanoid")

	if enabled then
		-- Constantly force walk speed
		humanoid.WalkSpeed = 220

		-- Noclip (ignore certain parts to prevent falling through ground)
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "LowerTorso" then
				part.CanCollide = false
				noclipParts[part] = true
			end
		end
	else
		-- Reset all changed parts
		for part in pairs(noclipParts) do
			if part:IsDescendantOf(game) and part:IsA("BasePart") then
				part.CanCollide = true
			end
		end
		noclipParts = {}

		-- Reset walk speed
		if humanoid then
			humanoid.WalkSpeed = 16
		end
	end
end)
