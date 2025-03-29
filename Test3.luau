repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local plr = Players.LocalPlayer
local Config = { NoFruitTime = 3 }

-- **🔵 Auto Join Marines**
task.spawn(function()
    while plr.Team ~= game.Teams.Marines do
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("SetTeam", "Marines")
        task.wait(1)
    end
end)

-- **🍏 UI Setup (Minimalist & Optimized)**
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local UIFrame = Instance.new("Frame", ScreenGui)
local UILabel = Instance.new("TextLabel", UIFrame)
local UICorner = Instance.new("UICorner", UIFrame)

ScreenGui.ResetOnSpawn = false
UIFrame.Size = UDim2.new(0, 260, 0, 60)
UIFrame.Position = UDim2.new(0.5, -130, 0.1, 0)
UIFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
UIFrame.BorderSizePixel = 2
UIFrame.BorderColor3 = Color3.fromRGB(255, 140, 0)
UICorner.CornerRadius = UDim.new(0, 10)

UILabel.Size = UDim2.new(1, -10, 1, -10)
UILabel.Position = UDim2.new(0, 5, 0, 5)
UILabel.BackgroundTransparency = 1
UILabel.TextColor3 = Color3.fromRGB(255, 255, 255)
UILabel.Font = Enum.Font.Cartoon
UILabel.TextXAlignment = Enum.TextXAlignment.Left
UILabel.TextScaled = true
UILabel.Text = "🍏 Fruit: ??? | 📍 Distance: ??? | ⏳ Hop: 3s"

-- **🍏 Detect & Teleport to Fruits**
task.spawn(function()
    while task.wait(0.03) do
        if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then continue end
        local root = plr.Character.HumanoidRootPart
        root.AssemblyLinearVelocity = Vector3.zero
        root.CanCollide = false

        local closestFruit, closestDistance = nil, math.huge

        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Tool") and not v.Parent:IsA("Player") and v:FindFirstChild("Handle") then
                local fruitPos = v.Handle.Position
                local distance = (root.Position - fruitPos).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestFruit = v
                end
            end
        end

        if closestFruit then
            local fruitPos = closestFruit.Handle.Position
            if closestDistance <= 40 then
                root.CFrame = CFrame.new(fruitPos)
            else
                local direction = (fruitPos - root.Position).Unit
                root.CFrame = root.CFrame + direction * 15
            end
            Config.NoFruitTime = 3
            UILabel.Text = "🍏 Fruit: " .. closestFruit.Name .. " | 📍 Distance: " .. math.floor(closestDistance) .. "m | ⏳ Hop: 3s"
        else
            Config.NoFruitTime = math.max(0, Config.NoFruitTime - 0.03)
            UILabel.Text = "🍏 Fruit: ??? | 📍 Distance: ??? | ⏳ Hop: " .. string.format("%.1f", Config.NoFruitTime) .. "s"
        end
    end
end)

-- **🌍 Server Hop System (Only Joins Servers with 3+ Players)**
local function FindAndJoinServer()
    local PlaceID = game.PlaceId
    local Servers
    local success, err = pcall(function()
        local response = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100"))
        Servers = response.data
    end)

    if not success or not Servers then
        warn("❌ Failed to retrieve servers. Trying again later.")
        return
    end

    -- **Filter servers with 3+ players**
    local ValidServers = {}
    for _, server in ipairs(Servers) do
        if server.playing >= 3 and server.playing < server.maxPlayers then
            table.insert(ValidServers, server.id)
        end
    end

    -- **If no valid servers, notify the player**
    if #ValidServers == 0 then
        warn("⚠️ No suitable servers found. Try again later.")
        return
    end

    -- **Randomly select a server and teleport**
    local SelectedServer = ValidServers[math.random(1, #ValidServers)]
    TeleportService:TeleportToPlaceInstance(PlaceID, SelectedServer, plr)
end

-- **🔄 Constantly Check for Server Hop**
task.spawn(function()
    while task.wait(0.2) do
        if Config.NoFruitTime <= 0 then
            FindAndJoinServer()
        end
    end
end)

-- **🛠️ Auto Store Fruits**
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            for _, fr in ipairs(plr.Backpack:GetChildren()) do
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", fr:GetAttribute("OriginalName"), fr)
            end
            for _, fr in ipairs(plr.Character:GetChildren()) do
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", fr:GetAttribute("OriginalName"), fr)
            end
        end)
    end
end)
