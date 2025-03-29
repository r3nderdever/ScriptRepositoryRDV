-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

-- Variables
local plr = Players.LocalPlayer
timer = 3
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

-- Server Hop Function with Fix
local function ServerHop()
    while true do
        local success, response = pcall(function()
            local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
            local validServers = {}
            
            for _, server in ipairs(servers.data) do
                if server.playing > 0 and server.id ~= game.JobId then
                    table.insert(validServers, server.id)
                end
            end

            if #validServers > 0 then
                local selectedServer = validServers[math.random(1, #validServers)]
                TeleportService:TeleportToPlaceInstance(game.PlaceId, selectedServer)
            else
                warn("No valid servers found. Retrying...")
            end
        end)

        if success then
            return
        else
            warn("Server hop failed: " .. tostring(response))
            task.wait(1)
        end
    end
end

-- Enable Collision with Water Parts
local function EnableWaterCollision()
    while task.wait(0.5) do
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and string.lower(part.Name):find("water") then
                part.CanCollide = true
            end
        end
    end
end

-- Start Processes
task.spawn(CheckAndJoinTeam)
task.spawn(AutoStoreLoop)
task.spawn(EnableWaterCollision)
task.spawn(function()
    while task.wait(0.024) do
        local fruit, distance = GetNearestFruit()
        if fruit then
            if distance > 50 then
                local direction = (fruit.Handle.Position - plr.Character.HumanoidRootPart.Position).unit * 3.4
                plr.Character:Move(direction)
            else
                plr.Character.HumanoidRootPart.CFrame = fruit.Handle.CFrame
            end
        else
            ServerHop()
        end
    end
end)
