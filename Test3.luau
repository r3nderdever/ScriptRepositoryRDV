repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local plr = Players.LocalPlayer
local Config = {
    AutoFruit = true,
    AutoStoreFruit = true,
    FruitLog = {},
    NoFruitTime = 0 -- Timer to track how long no fruits are found
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

task.wait(1)

-- **🍏 Detect & Teleport to Fruits**
local function TeleportToNearestFruit()
    while task.wait(0.12) do
        if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then continue end

        local root = plr.Character.HumanoidRootPart
        root.AssemblyLinearVelocity = Vector3.zero -- Prevents being pushed
        root.CanCollide = false                    -- Ignores collision

        local closestFruit = nil
        local closestDistance = math.huge

        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Tool") and v.Name:lower():find("fruit") then
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
                root.CFrame = CFrame.new(fruitPos) -- Instantly teleports if within 50 studs
            else
                local direction = (fruitPos - root.Position).Unit
                root.CFrame = root.CFrame + direction * 20 -- Moves 20 studs towards fruit
            end
            Config.NoFruitTime = 0 -- Reset timer since a fruit is found
        else
            Config.NoFruitTime += 0.12 -- Increase no-fruit timer
        end
    end
end

task.spawn(TeleportToNearestFruit)

-- **🌍 UI Setup**
local function CreateUI()
    local screenGui = Instance.new("ScreenGui", plr:FindFirstChildOfClass("PlayerGui"))

    local function CreateLabel(text, position)
        local label = Instance.new("TextLabel")
        label.Parent = screenGui
        label.Size = UDim2.new(0, 260, 0, 50)
        label.Position = position
        label.BackgroundColor3 = Color3.new(0, 0, 0)
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Text = text
        label.Font = Enum.Font.SourceSansBold
        label.TextSize = 20
        label.BorderSizePixel = 3
        label.BorderColor3 = Color3.fromRGB(255, 165, 0) -- Orange outline
        return label
    end

    local fruitLabel = CreateLabel("🍏 Fruit Name: ???\n📍 Fruit Distance: ???", UDim2.new(0.5, -130, 0, 50))
    local statusLabel = CreateLabel("🔍 Scanning for Fruits...", UDim2.new(0.5, -130, 0, 110))
    local creditLabel = CreateLabel("Made by R3nderDV. On Discord!", UDim2.new(0.5, -130, 0, 170))

    return fruitLabel, statusLabel
end

local fruitLabel, statusLabel = CreateUI()

-- **🍏 Update Fruit Info in UI**
local function UpdateFruitUI()
    while task.wait(1) do
        local closestFruit = nil
        local closestDistance = math.huge

        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Tool") and v.Name:lower():find("fruit") then
                local fruitPos = v:FindFirstChild("Handle") and v.Handle.Position
                if fruitPos then
                    local distance = (plr.Character.HumanoidRootPart.Position - fruitPos).Magnitude
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
            Config.NoFruitTime = 0 -- Reset no-fruit timer
        else
            fruitLabel.Text = "🍏 Fruit Name: ???\n📍 Fruit Distance: ???"
            statusLabel.Text = "🔍 Scanning for Fruits..."
            Config.NoFruitTime += 1 -- Increase no-fruit timer every second
        end
    end
end

task.spawn(UpdateFruitUI)

-- **🌍 Server Hop System (Only if No Fruits Found)**
local function ServerHop()
    if Config.NoFruitTime < 60 then return end -- Only server hop if 60s passed with no fruit

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

-- **🛠️ Check for Server Hop Every 5s**
task.spawn(function()
    while task.wait(5) do
        ServerHop()
    end
end)

-- **🚀 Prevent Physics Interference**
task.spawn(function()
    while task.wait() do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            root.AssemblyLinearVelocity = Vector3.zero -- Freezes movement from physics
            root.CanCollide = false -- No pushback from objects
        end
    end
end)
