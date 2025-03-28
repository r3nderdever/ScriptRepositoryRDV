local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local plr = Players.LocalPlayer
local timer = 0
local Config = { AutoStoreFruit = true }
local hasJoinedTeam = false
local hasSpawned = false

local fruitsList = {
    "Rocket Fruit", "Spin Fruit", "Chop Fruit", "Spring Fruit", "Bomb Fruit", "Spike Fruit",
    "Smoke Fruit", "Blade Fruit", "Sand Fruit", "Ice Fruit", "Dark Fruit", "Diamond Fruit",
    "Light Fruit", "Rubber Fruit", "Barrier Fruit", "Magma Fruit", "Phoenix Fruit", "Love Fruit",
    "Spider Fruit", "Sound Fruit", "Buddha Fruit", "Quake Fruit", "Gravity Fruit", "Control Fruit",
    "T-Rex Fruit", "Mammoth Fruit", "Spirit Fruit", "Venom Fruit", "Shadow Fruit", "Rumble Fruit",
    "Portal Fruit", "Blizzard Fruit", "Dragon Fruit", "Leopard Fruit", "Dough Fruit", "Dragon (West) Fruit",
    "Dragon (East) Fruit", "Kitsune Fruit", "Gas Fruit", "Yeti Fruit"
}

-- ✅ **Waits 2 seconds before joining Marines**
local function JoinTeam()
    task.wait(2)
    local teamRemote = ReplicatedStorage.Remotes.CommF_
    
    if plr.Team ~= game.Teams.Marines then
        teamRemote:InvokeServer("SetTeam", "Marines")
    end
    
    repeat task.wait(0.5) until plr.Team == game.Teams.Marines
    hasJoinedTeam = true
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

-- ✅ **Creates UI Elements**
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    
    local TopText = Instance.new("TextLabel", ScreenGui)
    TopText.Size = UDim2.new(1, 0, 0.1, 0)
    TopText.Position = UDim2.new(0, 0, 0, 0)
    TopText.BackgroundTransparency = 1
    TopText.Text = "Made By R3nderDV. On Discord."
    TopText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TopText.TextScaled = true
    TopText.Font = Enum.Font.SourceSansBold
    
    local FruitText = Instance.new("TextLabel", ScreenGui)
    FruitText.Size = UDim2.new(1, 0, 0.1, 0)
    FruitText.Position = UDim2.new(0, 0, 0.75, 0)
    FruitText.BackgroundTransparency = 1
    FruitText.Text = "Fruit: Searching... | Distance: N/A"
    FruitText.TextColor3 = Color3.fromRGB(255, 255, 255)
    FruitText.TextScaled = true
    FruitText.Font = Enum.Font.SourceSansBold
    
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

-- ✅ **Smoothly Updates UI**
local function UpdateUI()
    local label, snakeLabel = CreateUI()
    local snakePatterns = {".", "..", "...", "....", ".....", "......", ".....", "....", "...", ".."}
    local snakeIndex = 1

    while true do
        local nearestFruit, distance = GetNearestFruit()
        
        if nearestFruit then
            label.Text = "Fruit: " .. nearestFruit.Name .. " | Distance: " .. math.floor(distance) .. " studs"
        else
            label.Text = "No fruit found"
        end
        
        snakeLabel.Text = snakePatterns[snakeIndex]
        snakeIndex = (snakeIndex % #snakePatterns) + 1
        
        task.wait(0.1)
    end
end

-- ✅ **Server Hop Only Starts After Team Join & Spawn**
local function ServerHop()
    repeat task.wait(0.1) until hasJoinedTeam and hasSpawned
    
    task.wait(2) -- **Waits 2 seconds before server hop**
    local success, response = pcall(function()
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        local validServers = {}

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

-- ✅ **Ensures Player is Fully Spawned Before Running Scripts**
plr.CharacterAdded:Connect(function(char)
    task.wait(2)
    local hrp = char:WaitForChild("HumanoidRootPart")
    local humanoid = char:WaitForChild("Humanoid")

    humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
    humanoid.AutoRotate = true

    hasSpawned = true
    JoinTeam()
    task.spawn(UpdateUI)
    task.spawn(ServerHop)
end)

-- 🚀 **Start Everything**
task.spawn(JoinTeam)
task.spawn(UpdateUI)
task.spawn(ServerHop)
