--> Perfect R6 Ragdoll by CompletedLoop
--> Modified for LocalScript in StarterCharacterScripts
local Character = script.Parent
local Humanoid = Character:WaitForChild("Humanoid")
local Torso = Character:WaitForChild("Torso")

--> Ensure script runs only when character is fully loaded
if not Character:IsDescendantOf(game.Players.LocalPlayer.Character) then
	return
end

--> Necessary for Ragdolling
Humanoid.BreakJointsOnDeath = false
Humanoid.RequiresNeck = false

--> Store CFrame offsets for best-looking ragdoll
local attachmentCFrames = {
	["Neck"] = {CFrame.new(0, 1, 0), CFrame.new(0, -0.5, 0)},
	["Left Shoulder"] = {CFrame.new(-1.3, 0.75, 0), CFrame.new(0.2, 0.75, 0)},
	["Right Shoulder"] = {CFrame.new(1.3, 0.75, 0), CFrame.new(-0.2, 0.75, 0)},
	["Left Hip"] = {CFrame.new(-0.5, -1, 0), CFrame.new(0, 1, 0)},
	["Right Hip"] = {CFrame.new(0.5, -1, 0), CFrame.new(0, 1, 0)},
}

--> Create the "IsRagdoll" BoolValue
local RagdollValue = Instance.new("BoolValue")
RagdollValue.Name = "IsRagdoll"
RagdollValue.Parent = Character

--> Allows proper limb collisions
local function createColliderPart(part)
	if not part then return end
	local rp = Instance.new("Part")
	rp.Name = "ColliderPart"
	rp.Size = part.Size / 1.7
	rp.Massless = true
	rp.CFrame = part.CFrame
	rp.Transparency = 1

	local wc = Instance.new("WeldConstraint")
	wc.Part0 = rp
	wc.Part1 = part
	wc.Parent = rp
	rp.Parent = part
end

--> Converts Motor6D to BallSocketConstraints
local function replaceJoints()
	for _, motor in pairs(Character:GetDescendants()) do
		if motor:IsA("Motor6D") and attachmentCFrames[motor.Name] then
			motor.Enabled = false
			local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
			a0.CFrame = attachmentCFrames[motor.Name][1]
			a1.CFrame = attachmentCFrames[motor.Name][2]
			a0.Name = "RagdollAttachment"
			a1.Name = "RagdollAttachment"

			createColliderPart(motor.Part1)

			local b = Instance.new("BallSocketConstraint")
			b.Attachment0 = a0
			b.Attachment1 = a1
			b.Name = "RagdollConstraint"
			b.LimitsEnabled = true
			b.UpperAngle = 90

			a0.Parent = motor.Part0
			a1.Parent = motor.Part1
			b.Parent = motor.Parent
		end
	end
	Humanoid.AutoRotate = false
end

--> Reset Joints
local function resetJoints()
	if Humanoid.Health < 1 then return end
	for _, instance in pairs(Character:GetDescendants()) do
		if instance:IsA("Motor6D") then
			instance.Enabled = true
		elseif instance.Name == "RagdollConstraint" or instance.Name == "ColliderPart" then
			instance:Destroy()
		end
	end
	Humanoid.AutoRotate = true
end

--> Trigger Ragdoll
local function Ragdoll(value)
	if value then replaceJoints() else resetJoints() end
end

--> Connect Events
RagdollValue.Changed:Connect(Ragdoll)
Humanoid.Died:Once(function()
	RagdollValue.Value = true
end)
