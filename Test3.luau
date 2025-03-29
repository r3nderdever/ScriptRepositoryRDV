repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local plr = Players.LocalPlayer
local Config = {
    AutoFruit = true,
    AutoStoreFruit = true,
    FruitLog = {}
}

-- **🔵 Auto Join Marines**
local function JoinMarines()
    while plr.Team ~= game.Teams:FindFirstChild("Marines") do
        pcall(function()
            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("SetTeam", "Marines")
        end)
        task.wait(1)
    end
end
task.spawn(JoinMarines)

-- **📜 Load & Save Fruit Log**
local function LoadFruitLog()
    if isfile("fruitlog.json") then
        Config.FruitLog = HttpService:JSONDecode(readfile("fruitlog.json"))
    end
end

local function SaveFruitLog()
    writefile("fruitlog.json", HttpService:JSONEncode(Config.FruitLog))
end

local function LogFruit(fruitName)
    table.insert(Config.FruitLog, {
        fruit = fruitName,
        time = os.date("%Y-%m-%d %H:%M:%S")
    })
    SaveFruitLog()
end

task.wait(1)

-- **🛠️ Auto Store Fruits**
local function HandleAutoStore(tool)
    if Config.AutoStoreFruit and tool:IsA("Tool") and tool.Name:find("Fruit") then
        task.spawn(function()
            if tool.Parent then -- Ensure tool exists before storing
                pcall(function()
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", tool:GetAttribute("OriginalName"), tool)
                end)
            end
        end)
    end
end

task.spawn(function()
    while task.wait(2) do
        if Config.AutoStoreFruit then
            pcall(function()
                for _, fr in ipairs(plr.Backpack:GetChildren()) do
                    HandleAutoStore(fr)
                end
                if plr.Character then
                    for _, fr in ipairs(plr.Character:GetChildren()) do
                        HandleAutoStore(fr)
                    end
                end
            end)
        end
    end
end)

plr.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(HandleAutoStore)
end)

if plr.Character then
    plr.Character.ChildAdded:Connect(HandleAutoStore)
end

-- **🍏 Detect Fruits**
local function DetectFruits(fruitLabel, statusLabel)
    while task.wait(1) do
        local closestFruit = nil
        local closestDistance = math.huge

        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Tool") and v.Name:lower():find("fruit") then
                local fruitPos = v:FindFirstChild("Handle") and v.Handle.Position
                if fruitPos then
                    local distance = (plr.Character.HumanoidRootPart.Position - fruitPos).magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestFruit = v
                    end
                end
            end
        end

        if closestFruit then
            fruitLabel.Text = "🍏 Fruit Name: " .. closestFruit.Name .. "\n📍 Fruit Distance: " .. math.floor(closestDistance) .. "m"
            statusLabel.Text = "✅ Fruit Found!"
        else
            fruitLabel.Text = "🍏 Fruit Name: ???\n📍 Fruit Distance: ???"
            statusLabel.Text = "🔍 Scanning for Fruits..."
        end
    end
end

-- **🌍 Advanced Server Hop System**
local function ServerHop(statusLabel)
    statusLabel.Text = "🌍 Server Hopping..."
    task.wait(2)

    local success, servers = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)

    if success and servers and servers.data and #servers.data > 0 then
        local server = servers.data[math.random(1, #servers.data)]
        if server and server.id then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
        end
    else
        statusLabel.Text = "❌ No Servers Found!"
    end
end

-- **🚀 Run Everything**
local function MainLoop()
    local ScreenGui = Instance.new("ScreenGui", plr:FindFirstChildOfClass("PlayerGui"))
    local fruitLabel = Instance.new("TextLabel")
    local statusLabel = Instance.new("TextLabel")

    fruitLabel.Parent = ScreenGui
    statusLabel.Parent = ScreenGui

    fruitLabel.Size = UDim2.new(0, 250, 0, 50)
    fruitLabel.Position = UDim2.new(0.5, -125, 0, 50)
    fruitLabel.BackgroundColor3 = Color3.new(0, 0, 0)
    fruitLabel.TextColor3 = Color3.new(1, 1, 1)
    fruitLabel.Text = "🍏 Fruit Name: ???\n📍 Fruit Distance: ???"
    
    statusLabel.Size = UDim2.new(0, 250, 0, 50)
    statusLabel.Position = UDim2.new(0.5, -125, 0, 100)
    statusLabel.BackgroundColor3 = Color3.new(0, 0, 0)
    statusLabel.TextColor3 = Color3.new(1, 1, 1)
    statusLabel.Text = "🔍 Scanning for Fruits..."

    task.spawn(function()
        DetectFruits(fruitLabel, statusLabel)
    end)

    -- **Auto Server Hop After 60s**
    task.delay(60, function()
        ServerHop(statusLabel)
    end)
end

task.spawn(MainLoop)
