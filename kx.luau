local Character = script.Parent
local Humanoid = Character:WaitForChild("Humanoid")
local ragdollJoints = {}

Humanoid.BreakJointsOnDeath = false -- Prevent default Roblox joint breaking

-- Function to enable ragdoll
local function enableRagdoll()
	for _, Part in ipairs(Character:GetChildren()) do
		if Part:IsA("BasePart") then
			local Motor6D = Part:FindFirstChildWhichIsA("Motor6D")
			if Motor6D then
				local Part0, Part1 = Motor6D.Part0, Motor6D.Part1
				if Part0 and Part1 then
					if Part.Name ~= "Head" then
						-- Create physics-based BallSocketConstraint
						local BallSocket = Instance.new("BallSocketConstraint")
						local Attachment1 = Instance.new("Attachment")
						local Attachment2 = Instance.new("Attachment")
						
						Attachment1.CFrame = Motor6D.C0
						Attachment2.CFrame = Motor6D.C1
						Attachment1.Parent = Part0
						Attachment2.Parent = Part1
						
						BallSocket.Attachment0 = Attachment1
						BallSocket.Attachment1 = Attachment2
						BallSocket.Parent = Part1

						-- Store original joint for later restoration
						ragdollJoints[Part1] = { Motor6D, BallSocket }
						
						-- Remove the Motor6D joint
						Motor6D:Destroy()
					else
						-- Keep the head attached using a WeldConstraint
						local WeldConstraint = Instance.new("WeldConstraint")
						WeldConstraint.Part0 = Part0
						WeldConstraint.Part1 = Part1
						WeldConstraint.Parent = Part1
						
						-- Store for restoration
						ragdollJoints[Part1] = { Motor6D, WeldConstraint }
						Motor6D:Destroy()
					end
				end
			end
		end
	end
end

-- Function to disable ragdoll and restore original joints
local function disableRagdoll()
	for Part, data in pairs(ragdollJoints) do
		local OriginalMotor6D, Constraint = data[1], data[2]
		if Constraint then Constraint:Destroy() end -- Remove BallSocket or Weld
		if OriginalMotor6D then -- Restore original Motor6D joint
			local NewMotor6D = Instance.new("Motor6D")
			NewMotor6D.Part0 = OriginalMotor6D.Part0
			NewMotor6D.Part1 = Part
			NewMotor6D.C0 = OriginalMotor6D.C0
			NewMotor6D.C1 = OriginalMotor6D.C1
			NewMotor6D.Parent = Part
		end
	end
	ragdollJoints = {} -- Clear stored joints
end

-- Detect when the player takes damage
local lastHealth = Humanoid.Health
Humanoid.HealthChanged:Connect(function(newHealth)
	if newHealth < lastHealth then -- Only trigger when damaged
		enableRagdoll() -- Make player fall over
		task.wait(2) -- Wait for 2 seconds
		disableRagdoll() -- Restore character control
	end
	lastHealth = newHealth -- Update health tracker
end)
