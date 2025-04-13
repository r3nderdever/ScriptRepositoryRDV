local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Camera = workspace.CurrentCamera

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "CoordinateGUI"

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 40)
MainFrame.Position = UDim2.new(0.5, -150, 0, -50)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.AnchorPoint = Vector2.new(0.5, 0)
MainFrame.BackgroundTransparency = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 12)

-- Tween In Animation
TweenService:Create(MainFrame, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, -150, 0, 10)
}):Play()

-- Coordinate Label
local CoordLabel = Instance.new("TextLabel", MainFrame)
CoordLabel.Size = UDim2.new(1, -40, 1, 0)
CoordLabel.Position = UDim2.new(0, 10, 0, 0)
CoordLabel.BackgroundTransparency = 1
CoordLabel.Font = Enum.Font.ComicSans
CoordLabel.TextColor3 = Color3.new(1, 1, 1)
CoordLabel.TextScaled = true
CoordLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Dropdown Toggle Button (Circle)
local ToggleButton = Instance.new("TextButton", MainFrame)
ToggleButton.Size = UDim2.new(0, 40, 1, 0)
ToggleButton.Position = UDim2.new(1, -40, 0, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.Text = "+"
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextScaled = true
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)

local CircleUICorner = Instance.new("UICorner", ToggleButton)
CircleUICorner.CornerRadius = UDim.new(1, 0)

-- Dropdown Container
local DropdownFrame = Instance.new("Frame", MainFrame)
DropdownFrame.Size = UDim2.new(1, 0, 0, 0)
DropdownFrame.Position = UDim2.new(0, 0, 1, 0)
DropdownFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
DropdownFrame.BorderSizePixel = 0
DropdownFrame.ClipsDescendants = true
DropdownFrame.Visible = false

local DropdownCorner = Instance.new("UICorner", DropdownFrame)
DropdownCorner.CornerRadius = UDim.new(0, 12)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Camera = workspace.CurrentCamera

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "CoordinateGUI"

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 40)
MainFrame.Position = UDim2.new(0.5, -150, 0, -50)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.AnchorPoint = Vector2.new(0.5, 0)
MainFrame.BackgroundTransparency = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 12)

-- Tween In Animation
TweenService:Create(MainFrame, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, -150, 0, 10)
}):Play()

-- Coordinate Label
local CoordLabel = Instance.new("TextLabel", MainFrame)
CoordLabel.Size = UDim2.new(1, -40, 1, 0)
CoordLabel.Position = UDim2.new(0, 10, 0, 0)
CoordLabel.BackgroundTransparency = 1
CoordLabel.Font = Enum.Font.ComicSans
CoordLabel.TextColor3 = Color3.new(1, 1, 1)
CoordLabel.TextScaled = true
CoordLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Dropdown Toggle Button (Circle)
local ToggleButton = Instance.new("TextButton", MainFrame)
ToggleButton.Size = UDim2.new(0, 40, 1, 0)
ToggleButton.Position = UDim2.new(1, -40, 0, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.Text = "+"
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextScaled = true
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)

local CircleUICorner = Instance.new("UICorner", ToggleButton)
CircleUICorner.CornerRadius = UDim.new(1, 0)

-- Dropdown Container
local DropdownFrame = Instance.new("Frame", MainFrame)
DropdownFrame.Size = UDim2.new(1, 0, 0, 0)
DropdownFrame.Position = UDim2.new(0, 0, 1, 0)
DropdownFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
DropdownFrame.BorderSizePixel = 0
DropdownFrame.ClipsDescendants = true
DropdownFrame.Visible = false

local DropdownCorner = Instance.new("UICorner", DropdownFrame)
DropdownCorner.CornerRadius = UDim.new(0, 12)

-- (place this where the DropdownFrame is defined, same as before)
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -10, 0, 30)
SearchBox.Position = UDim2.new(0, 5, 0, 5)
SearchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SearchBox.PlaceholderText = "Search player..."
SearchBox.TextColor3 = Color3.new(1, 1, 1)
SearchBox.TextScaled = true
SearchBox.Font = Enum.Font.ComicSans
SearchBox.ClearTextOnFocus = false

local SearchCorner = Instance.new("UICorner", SearchBox)
SearchCorner.CornerRadius = UDim.new(0, 8)

-- UIListLayout setup (adjusted to be below the search box)
ListLayout.Parent = DropdownFrame
ListLayout.Padding = UDim.new(0, 5)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Container for player buttons
local PlayerListFrame = Instance.new("Frame")
PlayerListFrame.Size = UDim2.new(1, 0, 1, -40)
PlayerListFrame.Position = UDim2.new(0, 0, 0, 40)
PlayerListFrame.BackgroundTransparency = 1
PlayerListFrame.ClipsDescendants = true
PlayerListFrame.Parent = DropdownFrame

local PlayerListLayout = ListLayout:Clone()
PlayerListLayout.Parent = PlayerListFrame

SearchBox.Parent = DropdownFrame

-- Function to create player buttons
local function RefreshPlayerButtons(searchText)
	for _, btn in pairs(PlayerListFrame:GetChildren()) do
		if btn:IsA("TextButton") then
			btn:Destroy()
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and (not searchText or string.find(player.Name:lower(), searchText:lower())) then
			local btn = Instance.new("TextButton", PlayerListFrame)
			btn.Size = UDim2.new(1, -10, 0, 30)
			btn.Position = UDim2.new(0, 5, 0, 0)
			btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			btn.TextScaled = true
			btn.Font = Enum.Font.ComicSans
			btn.Text = player.Name

			local round = Instance.new("UICorner", btn)
			round.CornerRadius = UDim.new(0, 8)

			btn.MouseButton1Click:Connect(function()
				if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					TweenToCFrame(player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0))
				end
			end)
		end
	end
end

-- Real-time filtering
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	RefreshPlayerButtons(SearchBox.Text)
end)

-- Update ToggleButton function to use RefreshPlayerButtons
ToggleButton.MouseButton1Click:Connect(function()
	isOpen = not isOpen

	if isOpen then
		SearchBox.Text = ""
		DropdownFrame.Visible = true
		RefreshPlayerButtons()
		local newHeight = math.min(#Players:GetPlayers() * 35 + 40, 240)
		TweenService:Create(DropdownFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, 0, 0, newHeight)
		}):Play()
		ToggleButton.Text = "-"
	else
		TweenService:Create(DropdownFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, 0, 0, 0)
		}):Play()
		task.delay(0.4, function() DropdownFrame.Visible = false end)
		ToggleButton.Text = "+"
	end
end)
