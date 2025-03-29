repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local plr = Players.LocalPlayer
local Config = { NoFruitTime = 0 }

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

-- **📜 UI Setup**
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local UIFrame = Instance.new("Frame", ScreenGui)
local UIText = Instance.new("TextLabel", UIFrame)

ScreenGui.ResetOnSpawn = false
UIFrame.Size = UDim2.new(0, 250, 0, 100)
UIFrame.Position = UDim2.new(0.5, -125, 0.1, 0)
UIFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Black
UIFrame.BorderSizePixel = 3
UIFrame.BorderColor3 = Color3.fromRGB(255, 140, 0) -- Orange outline
UIFrame.BackgroundTransparency = 0.3

UIText.Size = UDim2.new(1, 0, 1, 0)
UIText.BackgroundTransparency = 1
UIText.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text
UIText.Font = Enum.Font.Cartoon
UIText.TextScaled = true
UIText.Text = "🍏 Fruit Name: ???\n📍 Fruit Distance: ???\n🔍 Status: Searching...\n\n🛠️ Made by R3nderDV. on Discord"

local UICorner = Instance.new("UICorner", UIFrame)
UICorner.CornerRadius = UDim.new(0, 10) -- Rounded corners

-- **🍏 Detect & Teleport to Fruits**
local function TeleportToNearestFruit()
    while task.wait(0.06) do -- Updates every 0.06 seconds
        if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then continue end

        local root = plr.Character.HumanoidRootPart
        root.AssemblyLinearVelocity = Vector3.zero -- Prevents being pushed
        root.CanCollide = false -- Ignores collision

        local closestFruit, closestDistance = nil, math.huge

        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Tool") and ValidFruits[v.Name] then -- ✅ Only valid fruits
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
                root.CFrame = root.CFrame + direction * 8 -- Moves 8 studs every 0.04s
            end
            Config.NoFruitTime = 0 -- Reset timer since a fruit is found
            UIText.Text = "🍏 Fruit Name: " .. closestFruit.Name .. "\n📍 Fruit Distance: " .. math.floor(closestDistance) .. "m\n✅ Status: Found!"
        else
            Config.NoFruitTime += 0.06 -- Increase no-fruit timer
            UIText.Text = "🍏 Fruit Name: ???\n📍 Fruit Distance: ???\n🔍 Status: Searching..."
        end
    end
end

task.spawn(TeleportToNearestFruit)

-- **🌍 Server Hop (Only if No Fruits for 3 Seconds)**
local function ServerHop()
    if Config.NoFruitTime < 3 then return end -- Only server hop if 3s passed with no fruit

    task.wait(1) -- Small delay before hopping

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
            UIText.Text = "🌍 Server Hopping..."
            TeleportService:TeleportToPlaceInstance(game.PlaceId, validServers[math.random(1, #validServers)])
        end
    end
end

-- **🚀 Run Server Hop Check Every 0.5s**
task.spawn(function()
    while task.wait(0.5) do
        ServerHop()
    end
end)
