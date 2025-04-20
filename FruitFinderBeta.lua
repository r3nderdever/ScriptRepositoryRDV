-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")

-- Player
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local camera = Workspace.CurrentCamera

-- Webhook setup
local webhook = "https://discord.com/api/webhooks/1355686213662802110/Zb2ToOaLRgzBq33aMO3Z4pAEId-d68akqQwwKQagx092AziDLneZYTgw9rOsHRbWdWTi"
local function sendWebhook(title, desc)
    task.spawn(function()
        (syn and syn.request or fluxus and fluxus.request or fluxus_request or http and http.request or http_request)({
            Url = webhook,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode({
                content = "",
                embeds = {{
                    title = title,
                    description = desc,
                    color = 0xeba300
                }}
            })
        })
    end)
end

-- Send webhook on script execution
sendWebhook("Script Executed", "User: " .. player.Name .. " has executed the script.")

-- Save file
local saveFile = "RDVfruitNotifier201.json"
local savedSettings = {
    ESP = false,
    AutoStore = false,
}
if isfile(saveFile) then
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(saveFile))
    end)
    if success and typeof(data) == "table" then
        savedSettings = data
    end
end
local function saveSettings()
    writefile(saveFile, HttpService:JSONEncode(savedSettings))
end

-- UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local function createButtonEffect(button)
    local ring = Instance.new("Frame")
    ring.Size = button.Size
    ring.Position = UDim2.new(0.5, 0, 0.5, 0)
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.BackgroundColor3 = button.BackgroundColor3
    ring.BackgroundTransparency = 0.2
    ring.BorderSizePixel = 0
    ring.ZIndex = 0
    ring.Parent = button

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ring

    local tweenOut = TweenService:Create(ring, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(1.5, 0, 1.5, 0),
        BackgroundTransparency = 1
    })
    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        ring:Destroy()
    end)
end

local function createStyledButton(text, pos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.1, 0, 0.08, 0)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        createButtonEffect(btn)
    end)
    return btn
end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.3, 0, 0.08, 0)
frame.Position = UDim2.new(0.5, 0, 0.01, 0)
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
frame.Parent = screenGui
frame.ClipsDescendants = true
frame.ZIndex = 1

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0.2, 0)
uiCorner.Parent = frame

local fruitLabel = Instance.new("TextLabel")
fruitLabel.Size = UDim2.new(1, 0, 1, 0)
fruitLabel.BackgroundTransparency = 1
fruitLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fruitLabel.TextScaled = true
fruitLabel.Font = Enum.Font.GothamBold
fruitLabel.TextStrokeTransparency = 0
fruitLabel.TextStrokeColor3 = Color3.fromRGB(50, 50, 50)
fruitLabel.ZIndex = 2
fruitLabel.Parent = frame

-- Fruit List
local fruitsList = {
    "Fruit ", "Rocket Fruit", "Spin Fruit", "Ghost Fruit", "Spring Fruit", "Bomb Fruit", "Spike Fruit", "Smoke Fruit", "Blade Fruit",
    "Sand Fruit", "Ice Fruit", "Dark Fruit", "Diamond Fruit", "Light Fruit", "Rubber Fruit", "Barrier Fruit", "Magma Fruit", "Phoenix Fruit",
    "Love Fruit", "Spider Fruit", "Sound Fruit", "Buddha Fruit", "Quake Fruit", "Gravity Fruit", "Control Fruit", "T-Rex Fruit",
    "Mammoth Fruit", "Spirit Fruit", "Venom Fruit", "Shadow Fruit", "Rumble Fruit", "Portal Fruit", "Blizzard Fruit", "Dragon Fruit",
    "Leopard Fruit", "Dough Fruit", "Dragon (West) Fruit", "Dragon (East) Fruit", "Kitsune Fruit", "Gas Fruit", "Flame Fruit", "Yeti Fruit", "Creation Fruit", "Eagle Fruit"
}

-- Find nearest fruit
local function findNearestFruit()
    local nearest, minDist, count = nil, math.huge, 0
    for _, fruit in ipairs(Workspace:GetChildren()) do
        if table.find(fruitsList, fruit.Name) and fruit:FindFirstChild("Handle") then
            local dist = (humanoidRootPart.Position - fruit.Handle.Position).Magnitude
            count += 1
            if dist < minDist then
                minDist = dist
                nearest = fruit
            end
        end
    end
    return nearest, minDist, count
end

-- Fruit ESP
local activeBillboards = {}
local function createBillboard(fruit)
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 100, 0, 30)
    bb.Adornee = fruit:FindFirstChild("Handle")
    bb.AlwaysOnTop = true
    bb.Parent = fruit

    local label = Instance.new("TextLabel")
    label.Text = fruit.Name
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 0)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = bb
    return bb
end

local function updateESP()
    for _, gui in pairs(activeBillboards) do
        if gui and gui.Parent then gui:Destroy() end
    end
    table.clear(activeBillboards)

    if savedSettings.ESP then
        for _, fruit in ipairs(Workspace:GetChildren()) do
            if table.find(fruitsList, fruit.Name) and fruit:FindFirstChild("Handle") then
                table.insert(activeBillboards, createBillboard(fruit))
            end
        end
    end
end

task.spawn(function()
    while true do
        if savedSettings.ESP then updateESP() end
        task.wait(1)
    end
end)

-- Fruit Detection
local detectedFruits = {}
task.spawn(function()
    while true do
        local found = {}
        for _, fruit in ipairs(Workspace:GetChildren()) do
            if table.find(fruitsList, fruit.Name) and fruit:FindFirstChild("Handle") and not CollectionService:HasTag(fruit, "Detected") then
                local displayName = fruit.Name == "Fruit " and "Spawned Fruit" or fruit.Name
                table.insert(found, displayName)
                CollectionService:AddTag(fruit, "Detected")
                fruit:GetPropertyChangedSignal("Parent"):Connect(function()
                    if fruit.Parent == nil or fruit.Parent == player.Backpack or fruit:IsDescendantOf(player.Character) then
                        CollectionService:RemoveTag(fruit, "Detected")
                    end
                end)
            end
        end
        if #found > 0 then
            sendWebhook("Fruit Detected", "User: " .. player.Name .. "\nFruits: " .. table.concat(found, ", "))
        end
        task.wait(1.5)
    end
end)

-- Fruit Label UI Update
spawn(function()
    while true do
        if not isTypingFeedback then
            local nearest, distance, count = findNearestFruit()
            if nearest then
                fruitLabel.Text = "Nearest: " .. (nearest.Name == "Fruit " and "Spawned Fruit" or nearest.Name) .. " | Total Fruits: " .. count
            else
                fruitLabel.Text = "No fruits found in server"
            end
        end
        task.wait(0.05)
    end
end)

-- Auto Store function
local function autoStore()
    -- Only proceed if AutoStore is enabled in the saved settings
    if not savedSettings.AutoStore then return end

    -- Wait for the player's Backpack to exist
    local backpack = player:WaitForChild("Backpack")

    -- Iterate through all tools in the Backpack
    for _, tool in ipairs(backpack:GetChildren()) do
        -- Check if the tool is a "Tool" object and its name contains "Fruit"
        if tool:IsA("Tool") and tool.Name:find("Fruit") then
            -- Get the original name of the tool or default to its current name
            local original = tool:GetAttribute("OriginalName") or tool.Name

            -- Call the server function to store the fruit tool
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", original, tool)
        end
    end
end

-- Continuously call the autoStore function every 0.04 seconds
task.spawn(function()
    while true do
        autoStore()  -- Execute autoStore to store fruit tools
        task.wait(0.04)  -- Wait for 0.04 seconds before running again
    end
end)

-- Buttons
-- Ensure that createStyledButton is defined correctly before calling it
local function createStyledButton(text, pos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.1, 0, 0.08, 0)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        createButtonEffect(btn)
    end)

    return btn
end

-- Now create the buttons
local leftButton1 = createStyledButton("Auto TP: Off", UDim2.new(0.35, 0, 0.01, 0), Color3.fromRGB(255, 100, 100))

-- Initialize the autoTPEnabled state (assuming it's false initially)
local autoTPEnabled = false

-- Toggle Auto TP button
-- Ensure that screenGui is created
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Debug: Check if screenGui is created correctly
print("ScreenGui Created: ", screenGui)

-- Create the button
local leftButton1 = createStyledButton("Auto TP: Off", UDim2.new(0.35, 0, 0.01, 0), Color3.fromRGB(255, 100, 100))

-- Debug: Check if leftButton1 is created
if leftButton1 then
    print("leftButton1 Created: ", leftButton1)
else
    print("Error: leftButton1 is nil!")
end

-- Now, handle the Auto TP button logic
if leftButton1 then
    leftButton1.Text = "Auto TP: Off"
    leftButton1.BackgroundColor3 = Color3.fromRGB(255, 100, 100)

    -- Toggle Auto TP button
    leftButton1.MouseButton1Click:Connect(function()
        autoTPEnabled = not autoTPEnabled
        leftButton1.Text = "Auto TP: " .. (autoTPEnabled and "On" or "Off")
        leftButton1.BackgroundColor3 = autoTPEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        createButtonEffect(leftButton1)
    end)
end

-- Create other buttons
local leftButton2 = createStyledButton("Feedback", UDim2.new(0.225, 0, 0.01, 0), Color3.fromRGB(25, 25, 25))
local rightButton1 = createStyledButton("AutoStore: " .. (savedSettings.AutoStore and "On" or "Off"), UDim2.new(0.675, 0, 0.01, 0), Color3.fromRGB(100, 150, 255))
local rightButton2 = createStyledButton("ESP: " .. (savedSettings.ESP and "On" or "Off"), UDim2.new(0.8, 0, 0.01, 0), Color3.fromRGB(100, 255, 100))

-- Button Logic
-- Auto TP logic
local autoTPEnabled = false
local tweening = false

local lines = {} -- store Drawing objects for fruit lines

-- Function to clear old lines
local function clearLines()
	for _, line in pairs(lines) do
		if line and line.Remove then
			line:Remove()
		end
	end
	table.clear(lines)
end

-- Draw lines to all fruits
local function drawLines()
	clearLines()
	for _, fruit in ipairs(Workspace:GetChildren()) do
		if table.find(fruitsList, fruit.Name) and fruit:FindFirstChild("Handle") then
			local line = Drawing.new("Line")
			line.Thickness = 2
			line.Color = Color3.fromRGB(255, 255, 0)
			line.Visible = true
			line.From = camera:WorldToViewportPoint(humanoidRootPart.Position)
			line.To = camera:WorldToViewportPoint(fruit.Handle.Position)
			table.insert(lines, line)
		end
	end
end

-- Auto TP coroutine
task.spawn(function()
	while true do
		if autoTPEnabled and not tweening then
			local fruit, dist = findNearestFruit()
			if fruit then
				tweening = true
				local tweenTime = dist / 250
				local goal = {CFrame = CFrame.new(fruit.Handle.Position)}
				local tween = TweenService:Create(humanoidRootPart, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), goal)
				local camConn = RunService.RenderStepped:Connect(function()
					camera.CFrame = humanoidRootPart.CFrame
					drawLines()
				end)
				tween:Play()
				tween.Completed:Connect(function()
					camConn:Disconnect()
					tweening = false
					clearLines()
				end)
			end
		end
		task.wait(0.1)
	end
end)

rightButton1.MouseButton1Click:Connect(function()
    savedSettings.AutoStore = not savedSettings.AutoStore
    rightButton1.Text = "AutoStore: " .. (savedSettings.AutoStore and "On" or "Off")
    saveSettings()
end)

rightButton2.MouseButton1Click:Connect(function()
    savedSettings.ESP = not savedSettings.ESP
    rightButton2.Text = "ESP: " .. (savedSettings.ESP and "On" or "Off")
    saveSettings()
    updateESP()
end)

-- Enhanced Feedback Logic
local isTypingFeedback = false
local userFeedback = ""

leftButton2.MouseButton1Click:Connect(function()
    if isTypingFeedback then return end
    isTypingFeedback = true
    fruitLabel.Text = "Type Feedback Here!"
    fruitLabel.TextColor3 = Color3.fromRGB(200, 200, 200)

    local function resetUI()
        fruitLabel.TextColor3 = Color3.new(1, 1, 1)
        fruitLabel.Text = "No fruits found in server"
        leftButton2.Text = "Feedback"
        leftButton2.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        isTypingFeedback = false
        userFeedback = ""
    end

    local textBox = Instance.new("TextBox")
    textBox.Size = fruitLabel.Size
    textBox.Position = fruitLabel.Position
    textBox.BackgroundTransparency = 1
    textBox.TextScaled = true
    textBox.Text = ""
    textBox.ClearTextOnFocus = true
    textBox.Font = fruitLabel.Font
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.Parent = fruitLabel

    textBox.Focused:Connect(function()
        if textBox.Text == "Type Feedback Here!" then
            textBox.Text = ""
        end
    end)

    textBox:GetPropertyChangedSignal("Text"):Connect(function()
        if textBox.Text ~= "" and leftButton2.Text ~= "Send!" then
            leftButton2.Text = "Send!"
            leftButton2.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
        elseif textBox.Text == "" then
            leftButton2.Text = "Feedback"
            leftButton2.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        end
    end)

    local connection
    connection = leftButton2.MouseButton1Click:Connect(function()
        if textBox.Text ~= "" then
            sendWebhook("Feedback from " .. player.Name, textBox.Text)
            connection:Disconnect()
            textBox:Destroy()
            resetUI()
        end
    end)

    textBox:CaptureFocus()
end)
