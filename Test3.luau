repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer
task.wait(2) -- Wait 2 seconds after loading

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local plr = Players.LocalPlayer

-- List of fruits to target
local TargetFruits = {
    "Fruit ", "Rocket Fruit", "Spin Fruit", "Chop Fruit", "Spring Fruit", "Bomb Fruit", "Spike Fruit",
    "Smoke Fruit", "Blade Fruit", "Sand Fruit", "Ice Fruit", "Dark Fruit", "Diamond Fruit", "Light Fruit",
    "Rubber Fruit", "Barrier Fruit", "Magma Fruit", "Phoenix Fruit", "Love Fruit", "Spider Fruit",
    "Sound Fruit", "Buddha Fruit", "Quake Fruit", "Gravity Fruit", "Control Fruit", "T-Rex Fruit",
    "Mammoth Fruit", "Spirit Fruit", "Venom Fruit", "Shadow Fruit", "Rumble Fruit", "Portal Fruit",
    "Blizzard Fruit", "Dragon Fruit", "Leopard Fruit", "Dough Fruit", "Dragon (West) Fruit",
    "Dragon (East) Fruit", "Kitsune Fruit", "Gas Fruit", "Yeti Fruit"
}

-- Auto-Join Marines Team
local function JoinMarines()
    if plr.Team ~= game.Teams.Marines and plr.Team ~= game.Teams.Pirates then
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("SetTeam", "Marines")
    end
end
JoinMarines()

-- Function to store fruit
local function StoreFruit(tool)
    if tool:IsA("Tool") and table.find(TargetFruits, tool.Name) then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", tool:GetAttribute("OriginalName"), tool)
    end
end

-- Function to check and store all fruits in backpack & character
local function AutoStoreFruits()
    pcall(function()
        for _, fruit in ipairs(plr.Backpack:GetChildren()) do
            StoreFruit(fruit)
        end
        if plr.Character then
            for _, fruit in ipairs(plr.Character:GetChildren()) do
                StoreFruit(fruit)
            end
        end
    end)
end

-- Run AutoStoreFruits every 0.3 seconds
task.spawn(function()
    while task.wait(0.3) do
        AutoStoreFruits()
    end
end)

-- Store fruits if new items are added to character
plr.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(StoreFruit)
end)

if plr.Character then
    plr.Character.ChildAdded:Connect(StoreFruit)
end

-- UI Setup for Fruit Finder
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local MainFrame = Instance.new("Frame", ScreenGui)
    local StatusLabel = Instance.new("TextLabel", MainFrame)

    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    MainFrame.Position = UDim2.new(0.8, -150, 0.5, -75)
    MainFrame.Size = UDim2.new(0, 300, 0, 50)
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Size = UDim2.new(1, 0, 1, 0)
    StatusLabel.Font = Enum.Font.GothamMedium
    StatusLabel.Text = "Searching for Fruits..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusLabel.TextSize = 16
    StatusLabel.Parent = MainFrame

    return StatusLabel
end

local StatusLabel = CreateUI()

-- Find the nearest targeted fruit
local function FindNearestFruit()
    local nearestFruit, nearestDistance
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Tool") and table.find(TargetFruits, v.Name) then
            local distance = (plr.Character.HumanoidRootPart.Position - v.Handle.Position).magnitude
            if not nearestFruit or distance < nearestDistance then
                nearestFruit, nearestDistance = v, distance
            end
        end
    end
    return nearestFruit, nearestDistance
end

-- Fruit Collection Logic
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local fruit, distance = FindNearestFruit()
            if fruit then
                StatusLabel.Text = fruit.Name .. " - " .. math.floor(distance) .. "m"
                -- Move to fruit
                local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(fruit.Handle.Position + Vector3.new(0, 3, 0))
                end
            else
                StatusLabel.Text = "No fruit found... Server hopping soon."
                task.wait(3)
                -- Server hop if no fruit found
                local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
                local server = servers.data[math.random(1, #servers.data)]
                if server then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                end
            end
        end)
    end
end)

print("✅ Final Script Loaded: Auto Fruit Store, Marines Join, Server Hop, & UI with Targeted Fruits")
