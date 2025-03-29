local Players = game:GetService("Players")
local player = Players.LocalPlayer

local character = script.Parent
local humanoid = character:FindFirstChildOfClass("Humanoid")

if not humanoid then return end

-- Function to toggle ragdoll
local function setRagdoll(state)
	local character = humanoid.Parent
	if not character then return end

	for _, joint in ipairs(character:GetDescendants()) do
		if joint:IsA("Motor6D") then
			joint.Enabled = not state -- Disable Motor6D to enable ragdoll
		end
	end
end

-- Health Change Event
local lastHealth = humanoid.Health
humanoid.HealthChanged:Connect(function(newHealth)
	if newHealth < lastHealth then -- Only trigger on damage
		setRagdoll(true) -- Enable ragdoll
		task.wait(2) -- Wait for 2 seconds
		setRagdoll(false) -- Restore movement
	end
	lastHealth = newHealth -- Update health tracker
end)
