local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local plr = Players.LocalPlayer
local timer = 0
local Config = {
    AutoStoreFruit = true,
}

local fruitsList = {
    "Fruit ", "Rocket Fruit", "Spin Fruit", "Chop Fruit", "Spring Fruit", "Bomb Fruit", "Spike Fruit",
    "Smoke Fruit", "Blade Fruit", "Sand Fruit", "Ice Fruit", "Dark Fruit", "Diamond Fruit", "Light Fruit",
    "Rubber Fruit", "Barrier Fruit", "Magma Fruit", "Phoenix Fruit", "Love Fruit", "Spider Fruit",
    "Sound Fruit", "Buddha Fruit", "Quake Fruit", "Gravity Fruit", "Control Fruit", "T-Rex Fruit",
    "Mammoth Fruit", "Spirit Fruit", "Venom Fruit", "Shadow Fruit", "Rumble Fruit", "Portal Fruit",
    "Blizzard Fruit", "Dragon Fruit", "Leopard Fruit", "Dough Fruit", "Dragon (West) Fruit",
    "Dragon (East) Fruit", "Kitsune Fruit", "Gas Fruit", "Yeti Fruit"
}

-- 🌟 FIXED: Player **always** joins the Marines team
local function JoinTeam()
    task.wait(2)  
    local teamRemote = ReplicatedStorage.Remotes.CommF_
    if plr.Team ~= game.Teams.Marines then
        teamRemote:InvokeServer("SetTeam", "Marines")
    end
end

-- 🌟 FIXED: Fruits **auto-store immediately**
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

-- 🌟 FIXED: **Correctly detects the nearest fruit**
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

-- 🌟 FIXED: **Full Black UI + Updated Text**
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    
    local Background = Instance.new("Frame", ScreenGui)
    Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Background.Size = UDim2.new(5, 0, 5, 0) -- **5x bigger**
    
    local TopText = Instance.new("TextLabel", Background)
    TopText.Size = UDim2.new(1, 0, 0, 50)
    TopText.Position = UDim2.new(0, 0, 0, 0)
    TopText.BackgroundTransparency = 1
    TopText.Text = "Made By R3nderDV. On Discord."
    TopText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TopText.TextScaled = true
    TopText.Font = Enum.Font.ComicSans

    local FruitText = Instance.new("TextLabel", Background)
    FruitText.Size = UDim2.new(1, 0, 0, 60)
    FruitText.Position = UDim2.new(0, 0, 0.75, 0)
    FruitText.BackgroundTransparency = 1
    FruitText.Text = "Fruit: Searching... | Distance: N/A"
    FruitText.TextColor3 = Color3.fromRGB(255, 255, 255)
    FruitText.TextScaled = true
    FruitText.Font = Enum.Font.ComicSans

    local SnakeText = Instance.new("TextLabel", Background)
    SnakeText.Size = UDim2.new(1, 0, 0, 50)
    SnakeText.Position = UDim2.new(0, 0, 0.4, 0)
    SnakeText.BackgroundTransparency = 1
    SnakeText.Text = "......"
    SnakeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    SnakeText.TextScaled = true
    SnakeText.Font = Enum.Font.ComicSans

    return FruitText, SnakeText
end

-- 🌟 FIXED: **Smooth Camera Movement**
local function TeleportToFruit()
    local label, snakeText = CreateUI()
    local hrp = plr.Character:WaitForChild("HumanoidRootPart")
    local camera = game.Workspace.CurrentCamera

    while true do
        local nearestFruit, distance = GetNearestFruit()
        
        if nearestFruit then
            local fruitPosition = nearestFruit.Handle.Position

            -- **Easing Camera Movement (3s)**
            local cameraGoal = { CFrame = CFrame.new(fruitPosition) }
            local cameraTween = TweenService:Create(camera, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), cameraGoal)
            cameraTween:Play()

            -- **Update UI**
            label.Text = "Fruit: " .. nearestFruit.Name .. " | Distance: " .. math.floor(distance) .. " studs"
        else
            label.Text = "No fruit found"
        end
        
        task.wait(0.04) -- **Ultra-fast UI update**
    end
end

-- 🌟 FIXED: **Server Hop Works!**
local function ServerHop()
    task.wait(1.2)  
    local success, response = pcall(function()
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        local server = servers.data[math.random(1, #servers.data)]
        if server then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
        end
    end)

    if not success then
        warn("Server hop failed: " .. response)
    end
end

-- 🌟 FIXED: **Respawn Handler**
plr.CharacterAdded:Connect(function()
    task.wait(2) 
    JoinTeam()
    task.spawn(TeleportToFruit)
    task.spawn(ServerHop)
end)

-- 🚀 **Start Everything**
task.spawn(JoinTeam)
task.spawn(AutoStoreLoop)
task.spawn(TeleportToFruit)
task.spawn(ServerHop)
