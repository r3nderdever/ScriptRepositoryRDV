local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local plr = Players.LocalPlayer
local timer = 0
local Config = { AutoStoreFruit = true }
local hasJoinedTeam = false

local fruitsList = {
    "Fruit ", "Rocket Fruit", "Spin Fruit", "Chop Fruit", "Spring Fruit", "Bomb Fruit", "Spike Fruit",
    "Smoke Fruit", "Blade Fruit", "Sand Fruit", "Ice Fruit", "Dark Fruit", "Diamond Fruit", "Light Fruit",
    "Rubber Fruit", "Barrier Fruit", "Magma Fruit", "Phoenix Fruit", "Love Fruit", "Spider Fruit",
    "Sound Fruit", "Buddha Fruit", "Quake Fruit", "Gravity Fruit", "Control Fruit", "T-Rex Fruit",
    "Mammoth Fruit", "Spirit Fruit", "Venom Fruit", "Shadow Fruit", "Rumble Fruit", "Portal Fruit",
    "Blizzard Fruit", "Dragon Fruit", "Leopard Fruit", "Dough Fruit", "Dragon (West) Fruit",
    "Dragon (East) Fruit", "Kitsune Fruit", "Gas Fruit", "Yeti Fruit"
}

-- ✅ **Joins Marines Before Doing Anything Else**
local function JoinTeam()
    task.wait(2)
    local teamRemote = ReplicatedStorage.Remotes.CommF_
    
    if plr.Team ~= game.Teams.Marines then
        teamRemote:InvokeServer("SetTeam", "Marines")
    end
    
    repeat
        task.wait(0.5)
    until plr.Team == game.Teams.Marines
    
    hasJoinedTeam = true
end

-- ✅ **Auto-Stores Fruits**
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

-- ✅ **Finds the Nearest Fruit**
local function GetNearestFruit()
    local nearestFruit = nil
    local nearestDistance = math.huge
    for _, fruitName in ipairs(fruitsList) do
        local fruit = Workspace:FindFirstChild(fruitName)
        if fruit and fruit:FindFirstChild("Handle") then
            local distance = (plr.Character.HumanoidRootPart.Position - fruit.Handle.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestFruit = fruit
            end
        end
    end
    return nearestFruit, nearestDistance
end

-- ✅ **Creates UI for Fruit Info**
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    
    -- **Main Title**
    local TopText = Instance.new("TextLabel", ScreenGui)
    TopText.Size = UDim2.new(1, 0, 0.1, 0)
    TopText.Position = UDim2.new(0, 0, 0, 0)
    TopText.BackgroundTransparency = 1
    TopText.Text = "Made By R3nderDV. On Discord."
    TopText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TopText.TextScaled = true
    TopText.Font = Enum.Font.SourceSansBold
    
    -- **Fruit Information**
    local FruitText = Instance.new("TextLabel", ScreenGui)
    FruitText.Size = UDim2.new(1, 0, 0.1, 0)
    FruitText.Position = UDim2.new(0, 0, 0.75, 0)
    FruitText.BackgroundTransparency = 1
    FruitText.Text = "Fruit: Searching... | Distance: N/A"
    FruitText.TextColor3 = Color3.fromRGB(255, 255, 255)
    FruitText.TextScaled = true
    FruitText.Font = Enum.Font.SourceSansBold
    
    -- **Snake Animation**
    local SnakeText = Instance.new("TextLabel", ScreenGui)
    SnakeText.Size = UDim2.new(1, 0, 0.1, 0)
    SnakeText.Position = UDim2.new(0, 0, 0.4, 0)
    SnakeText.BackgroundTransparency = 1
    SnakeText.Text = "......"
    SnakeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    SnakeText.TextScaled = true
    SnakeText.Font = Enum.Font.SourceSansBold
    
    return FruitText, SnakeText
end

-- ✅ **Updates UI Smoothly**
local function TeleportToFruit()
    local label, snakeText = CreateUI()
    local hrp = plr.Character:WaitForChild("HumanoidRootPart")

    while true do
        local nearestFruit, distance = GetNearestFruit()
        
        if nearestFruit then
            label.Text = "Fruit: " .. nearestFruit.Name .. " | Distance: " .. math.floor(distance) .. " studs"
        else
            label.Text = "No fruit found"
        end
        
        task.wait(0.02) -- **Ultra-fast updates**
    end
end

-- ✅ **Server Hop Now Starts Only After Marines Join**
local function ServerHop()
    repeat task.wait(0.1) until hasJoinedTeam
    
    task.wait(2) -- Waits 2 seconds before hopping after team join
    local success, response = pcall(function()
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        local validServers = {}

        -- Filter for active servers
        for _, server in ipairs(servers.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                table.insert(validServers, server.id)
            end
        end
        
        if #validServers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, validServers[math.random(1, #validServers)])
        end
    end)

    if not success then
        warn("Server hop failed: " .. response)
    end
end

-- ✅ **Ensures Player Doesn’t Separate from Humanoid**
plr.CharacterAdded:Connect(function(char)
    task.wait(2)
    local hrp = char:WaitForChild("HumanoidRootPart")
    local humanoid = char:WaitForChild("Humanoid")

    -- Ensures proper physics
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
    humanoid.AutoRotate = true

    JoinTeam()
    task.spawn(TeleportToFruit)
    task.spawn(ServerHop)
end)

-- 🚀 **Start Everything**
task.spawn(JoinTeam)
task.spawn(AutoStoreLoop)
task.spawn(TeleportToFruit)
task.spawn(ServerHop)
