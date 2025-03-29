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

-- Function to join Marines
local function CheckAndJoinTeam()
    while true do
        if plr.Team ~= game.Teams.Marines then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Marines")
        else
            break
        end
        task.wait(0.5)
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
    while task.wait(0.5) do
        for _, tool in ipairs(plr.Backpack:GetChildren()) do
            HandleAutoStore(tool)
        end
    end
end

-- Create UI for Fruit Info
local function CreateFruitInfoUI()
    local screenGui = Instance.new("ScreenGui", plr.PlayerGui)
    
    local label = Instance.new("TextLabel", screenGui)
    label.Size = UDim2.new(0.5, 0, 0.05, 0)
    label.Position = UDim2.new(0.25, 0, 0.9, 0)
    label.BackgroundTransparency = 0.5
    label.BackgroundColor3 = Color3.new(0, 0, 0)
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Text = "Fruit Finder Inactive"
    
    local creditLabel = Instance.new("TextLabel", screenGui)
    creditLabel.Size = UDim2.new(1, 0, 0.05, 0)
    creditLabel.Position = UDim2.new(0, 0, 0, 0)
    creditLabel.BackgroundTransparency = 1
    creditLabel.TextColor3 = Color3.new(1, 1, 1)
    creditLabel.TextScaled = true
    creditLabel.Text = "Made by R3nderDV. On Discord"
    
    return label
end

local fruitLabel = CreateFruitInfoUI()

-- ESP Function
local function CreateESP(object)
    if not object:FindFirstChild("ESP") then
        local highlight = Instance.new("BillboardGui")
        highlight.Name = "ESP"
        highlight.Size = UDim2.new(0, 50, 0, 50)
        highlight.AlwaysOnTop = true
        highlight.Parent = object
        
        local frame = Instance.new("Frame", highlight)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = Color3.new(1, 0, 0)
        frame.BackgroundTransparency = 0.5
    end
end

-- Detect Nearest Fruit
local function GetNearestFruit()
    local nearestFruit, nearestDistance = nil, math.huge
    for _, fruitName in ipairs(fruitsList) do
        local fruit = Workspace:FindFirstChild(fruitName)
        if fruit and fruit:FindFirstChild("Handle") then
            local distance = (plr.Character.HumanoidRootPart.Position - fruit.Handle.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestFruit = fruit
            end
            CreateESP(fruit.Handle)
        end
    end
    return nearestFruit, nearestDistance
end

-- Noclip function
local function EnableNoclip()
    for _, part in ipairs(plr.Character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

local function DisableNoclip()
    for _, part in ipairs(plr.Character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end

-- Move Towards Nearest Fruit
local function MoveTowardsFruit()
    while task.wait(0.03) do
        if plr.Team == game.Teams.Marines then
            fruitLabel.Text = "Fruit Finder Active"
            local nearestFruit, distance = GetNearestFruit()
            if nearestFruit and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = plr.Character.HumanoidRootPart
                if distance <= 50 then
                    hrp.CFrame = CFrame.new(nearestFruit.Handle.Position)
                else
                    local direction = (nearestFruit.Handle.Position - hrp.Position).unit
                    hrp.CFrame = CFrame.new(hrp.Position + direction * 5)
                end
                
                if distance > 20 then
                    EnableNoclip()
                else
                    DisableNoclip()
                end
                
                local waterBase = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("WaterBase-Plane")
                if waterBase and (hrp.Position - waterBase.Position).Magnitude <= 5 then
                    hrp.CFrame = hrp.CFrame + Vector3.new(0, 30, 0)
                end
                
                fruitLabel.Text = "Found: " .. nearestFruit.Name .. " | Distance: " .. math.floor(distance)
            else
                task.wait(1)
                if not GetNearestFruit() then
                    local success, response = pcall(function()
                        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
                        local server = servers.data[math.random(1, #servers.data)]
                        if server then TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id) end
                    end)
                    if not success then warn("Server hop failed: " .. response) end
                end
            end
        else
            fruitLabel.Text = "Fruit Finder Inactive"
        end
    end
end

-- On Respawn
plr.CharacterAdded:Connect(function()
    task.wait(1)
    task.spawn(MoveTowardsFruit)
end)

-- Start Processes
task.spawn(CheckAndJoinTeam)
task.spawn(AutoStoreLoop)
task.spawn(MoveTowardsFruit)
