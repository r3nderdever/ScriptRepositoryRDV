-- CONSTANT TELEPORT TO 5 STUDS IN FRONT OF PLAYER "QuantumR3nder"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local targetName = "QuantumR3nder"

-- How often to teleport (in seconds)
local teleportInterval = 0.1

-- Function to get position 5 studs in front of target
local function getPositionInFront(targetCharacter)
	if not targetCharacter then return end
	local hrp = targetCharacter:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	return hrp.CFrame.Position + (hrp.CFrame.LookVector * 5)
end

-- Loop
task.spawn(function()
	while true do
		local target = Players:FindFirstChild(targetName)
		if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
			local pos = getPositionInFront(target.Character)
			local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
			if pos and hrp then
				hrp.CFrame = CFrame.new(pos)
			end
		end
		task.wait(teleportInterval)
	end
end)
