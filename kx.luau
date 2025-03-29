local function createRagdoll(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R6 then return end
	
	-- Disable Motor6Ds and enable BallSocketConstraints (if they exist)
	for _, joint in pairs(character:GetDescendants()) do
		if joint:IsA("Motor6D") then
			joint.Enabled = false
		end
	end
end

local function restoreCharacter(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R6 then return end

	-- Re-enable Motor6Ds
	for _, joint in pairs(character:GetDescendants()) do
		if joint:IsA("Motor6D") then
			joint.Enabled = true
		end
	end
end

local function onCharacterAdded(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	
	-- Detect jumping to ragdoll
	humanoid.Jumping:Connect(function(isJumping)
		if isJumping then
			createRagdoll(character)
		end
	end)

	-- Detect landing to restore
	humanoid.StateChanged:Connect(function(_, newState)
		if newState == Enum.HumanoidStateType.Freefall then
			-- Wait until landed
			humanoid.StateChanged:Wait()
			restoreCharacter(character)
		end
	end)
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(onCharacterAdded)
end

game.Players.PlayerAdded:Connect(onPlayerAdded)
