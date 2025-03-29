repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local plr = Players.LocalPlayer
local Config = { NoFruitTime = 3 }

-- **🔵 Auto Join Marines**
local function JoinMarines()
    while plr.Team ~= game.Teams.Marines do
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("SetTeam", "Marines")
        task.wait(1)
    end
end
task.spawn(JoinMarines)

-- **✅ List of Valid Fruits**
local ValidFruits = {
    ["Fruit "] = true, ["Rocket Fruit"] = true, ["Spin Fruit"] = true, ["Chop Fruit"] = true, ["Spring Fruit"] = true,
    ["Bomb Fruit"] = true, ["Spike Fruit"] = true, ["Smoke Fruit"] = true, ["Blade Fruit"] = true, ["Sand Fruit"] = true,
    ["Ice Fruit"] = true, ["Dark Fruit"] = true, ["Diamond Fruit"] = true, ["Light Fruit"] = true, ["Rubber Fruit"] = true,
    ["Barrier Fruit"] = true, ["Magma Fruit"] = true, ["Phoenix Fruit"] = true, ["Love Fruit"] = true, ["Spider Fruit"] = true,
    ["Sound Fruit"] = true, ["Buddha Fruit"] = true, ["Quake Fruit"] = true, ["Gravity Fruit"] = true, ["Control Fruit"] = true,
    ["T-Rex Fruit"] = true, ["Mammoth Fruit"] = true, ["Spirit Fruit"] = true, ["Venom Fruit"] = true, ["Shadow Fruit"] = true,
    ["Rumble Fruit"] = true, ["Portal Fruit"] = true, ["Blizzard Fruit"] = true, ["Dragon Fruit"] = true, ["Leopard Fruit"] = true,
    ["Dough Fruit"] = true, ["Dragon (West) Fruit"] = true, ["Dragon (East) Fruit"] = true, ["Kitsune Fruit"] = true, ["Gas Fruit"] = true,
    ["Yeti Fruit"] = true
}

-- **🛠️ Auto Store Fruits**
local function StoreFruit(tool)
    if tool:IsA("Tool") and ValidFruits[tool.Name] then
        task.spawn(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", tool:GetAttribute("OriginalName"), tool)
        end)
    end
end

-- **📜 UI Setup**
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local UIFrame = Instance.new("Frame", ScreenGui)
local FruitLabel = Instance.new("TextLabel", UIFrame)
local DistanceLabel = Instance.new("TextLabel", UIFrame)
local TimerLabel = Instance.new("TextLabel", UIFrame)
local UICorner = Instance.new("UICorner", UIFrame)

ScreenGui.ResetOnSpawn = false
UIFrame.Size = UDim2.new(0, 280, 0, 90)
UIFrame.Position = UDim2.new(0.5, -140, 0.1, 0)
UIFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
UIFrame.BorderSizePixel = 2
UIFrame.BorderColor3 = Color3.fromRGB(255, 140, 0)
UICorner.CornerRadius = UDim.new(0, 10)

local function CreateTextLabel(parent, yOffset, fontSize)
    local label = Instance.new("TextLabel", parent)
    label.Size = UDim2.new(1, -10, 0, fontSize)
    label.Position = UDim2.new(0, 5, 0, yOffset)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Cartoon
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextScaled = false
    label.TextSize = fontSize
    return label
end

FruitLabel = CreateTextLabel(UIFrame, 5, 20)
DistanceLabel = CreateTextLabel(UIFrame, 30, 20)
TimerLabel = CreateTextLabel(UIFrame, 55, 20)

FruitLabel.Text = "🍏 Fruit Name: ???"
DistanceLabel.Text = "📍 Fruit Distance: ???"
TimerLabel.Text = "⏳ Server Hop In: 3s"

-- **🍏 Detect & Teleport to Fruits**
local function TeleportToNearestFruit()
    while task.wait(0.06) do
        if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then continue end

        local root = plr.Character.HumanoidRootPart
        root.AssemblyLinearVelocity = Vector3.zero
        root.CanCollide = false

        local closestFruit, closestDistance = nil, math.huge

        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Tool") and ValidFruits[v.Name] and not v.Parent:IsA("Player") then
                local fruitPos = v:FindFirstChild("Handle") and v.Handle.Position
                if fruitPos then
                    local distance = (root.Position - fruitPos).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestFruit = v
                    end
                end
            end
        end

        if closestFruit then
            local fruitPos = closestFruit.Handle.Position
            if closestDistance <= 50 then
                root.CFrame = CFrame.new(fruitPos)
            else
                local direction = (fruitPos - root.Position).Unit
                root.CFrame = root.CFrame + direction * 8
            end
            Config.NoFruitTime = 3
            FruitLabel.Text = "🍏 Fruit Name: " .. closestFruit.Name
            DistanceLabel.Text = "📍 Fruit Distance: " .. math.floor(closestDistance) .. "m"
        else
            Config.NoFruitTime = math.max(0, Config.NoFruitTime - 0.06)
            TimerLabel.Text = "⏳ Server Hop In: " .. string.format("%.1f", Config.NoFruitTime) .. "s"
        end
    end
end

task.spawn(TeleportToNearestFruit)

-- **🌍 Server Hop (Only if No Fruits for 3 Seconds)**
local function ServerHop()
    if Config.NoFruitTime > 0 then return end

    task.wait(1)

    local success, servers = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)

    if success and servers and servers.data and #servers.data > 0 then
        local validServers = {}

        for _, server in ipairs(servers.data) do
            if server.playing >= 3 and server.playing <= 11 and server.id ~= game.JobId then
                table.insert(validServers, server.id)
            end
        end

        if #validServers > 0 then
            TimerLabel.Text = "🌍 Server Hopping..."
            TeleportService:TeleportToPlaceInstance(game.PlaceId, validServers[math.random(1, #validServers)])
        end
    end
end

task.spawn(function()
    while task.wait(0.5) do
        ServerHop()
    end
end)

-- **🛠️ Auto Store Fruits (Constant Check)**
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            for _, fr in ipairs(plr.Backpack:GetChildren()) do
                StoreFruit(fr)
            end
            for _, fr in ipairs(plr.Character:GetChildren()) do
                StoreFruit(fr)
            end
        end)
    end
end)

plr.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(StoreFruit)
end)

if plr.Character then
    plr.Character.ChildAdded:Connect(StoreFruit)
end
