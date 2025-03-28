-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

-- Variables
local plr = Players.LocalPlayer
local timer = 3
local Config = { AutoStoreFruit = true }
local fruitsList = {
    "Fruit", "Rocket Fruit", "Spin Fruit", "Chop Fruit", "Spring Fruit", "Bomb Fruit", "Spike Fruit",
    "Smoke Fruit", "Blade Fruit", "Sand Fruit", "Ice Fruit", "Dark Fruit", "Diamond Fruit", "Light Fruit",
    "Rubber Fruit", "Barrier Fruit", "Magma Fruit", "Phoenix Fruit", "Love Fruit", "Spider Fruit",
    "Sound Fruit", "Buddha Fruit", "Quake Fruit", "Gravity Fruit", "Control Fruit", "T-Rex Fruit",
    "Mammoth Fruit", "Spirit Fruit", "Venom Fruit", "Shadow Fruit", "Rumble Fruit", "Portal Fruit",
    "Blizzard Fruit", "Dragon Fruit", "Leopard Fruit", "Dough Fruit", "Dragon (West) Fruit",
    "Dragon (East) Fruit", "Kitsune Fruit", "Gas Fruit", "Yeti Fruit"
}

-- Create UI for Message at the Very Top
local function CreateMessageUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = plr:WaitForChild("PlayerGui")

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Parent = screenGui
    messageLabel.Size = UDim2.new(1, 0, 0.05, 0)  -- Full width, small height
    messageLabel.Position = UDim2.new(0, 0, 0, 0) -- Very top of the screen
    messageLabel.BackgroundTransparency = 0.3
    messageLabel.BackgroundColor3 = Color3.new(0, 0, 0)
    messageLabel.TextColor3 = Color3.new(1, 1, 1)
    messageLabel.TextScaled = true
    messageLabel.Font = Enum.Font.SourceSansBold
    messageLabel.Text = "Made by R3nderDV. On Discord!"

    task.wait(5)  -- Show message for 5 seconds
    messageLabel:Destroy()
end

-- Function to join Marines
task.wait(2)
local function JoinTeam()
    if plr.Team ~= game.Teams.Marines then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Marines")
        repeat task.wait(1) until plr.Team == game.Teams.Marines
    end
end

-- Auto-Store Fruits
local function HandleAutoStore(tool)
    if Config.AutoStoreFruit and tool:IsA("Tool") and tool.Name:find("Fruit") then
        task.spawn(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", tool:GetAttribute("OriginalName"), tool)
        end)
    end
end
local function AutoStoreLoop()
    while true do
        for _, tool in ipairs(plr.Backpack:GetChildren()) do
            HandleAutoStore(tool)
        end
        task.wait(0.5)
    end
end

-- Start Processes
task.spawn(CreateMessageUI)
task.spawn(JoinTeam)
task.spawn(AutoStoreLoop)
