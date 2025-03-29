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

-- UI Setup
local function CreateUI()
    local screenGui = Instance.new("ScreenGui", plr.PlayerGui)
    
    local fruitLabel = Instance.new("TextLabel", screenGui)
    fruitLabel.Size = UDim2.new(1, 0, 0.05, 0)
    fruitLabel.Position = UDim2.new(0, 0, 0, 0)
    fruitLabel.BackgroundTransparency = 0.5
    fruitLabel.BackgroundColor3 = Color3.new(0, 0, 0)
    fruitLabel.TextColor3 = Color3.new(1, 1, 1)
    fruitLabel.TextScaled = true
    fruitLabel.Text = "Distance: ??? | Blox Fruit: ??? | Time Till ServerH: ???"
    
    return fruitLabel
end
local fruitLabel = CreateUI()

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

-- Remove water parts
local function RemoveWaterParts()
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Name:lower():find("water") then
            part:Destroy()
        end
    end
end

-- ESP Function
local function CreateESP(object)
    if not object:FindFirstChild("Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "Highlight"
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 1
        highlight.Parent = object
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

-- Movement System
local function MoveToFruit()
    while true do
        local fruit, distance = GetNearestFruit()
        if fruit then
            fruitLabel.Text = string.format("Distance: %.2f | Blox Fruit: %s | Time Till ServerH: %.1f", distance, fruit.Name, timer)
            
            -- Set gravity to 0 to prevent falling
            plr.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            plr.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            
            -- Move towards fruit
            local direction = (fruit.Handle.Position - plr.Character.HumanoidRootPart.Position).unit * 20
            plr.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame + direction
            
        else
            timer = timer - 0.1
            fruitLabel.Text = string.format("Distance: ??? | Blox Fruit: ??? | Time Till ServerH: %.1f", timer)
            if timer <= 0 then
                ServerHop()
            end
        end
        task.wait(0.12)
    end
end

-- Server Hop Function
local function ServerHop()
    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    
    if success and response and response.data then
        local server = response.data[math.random(1, #response.data)]
        if server then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
        end
    end
end

-- Start Processes
task.spawn(CheckAndJoinTeam)
task.spawn(AutoStoreLoop)
task.spawn(RemoveWaterParts)
task.spawn(MoveToFruit)
