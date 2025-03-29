-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- Variables
local plr = Players.LocalPlayer
local timer = 3
local Config = { AutoStoreFruit = true }
local teleportSpeed = 150 -- studs per second
local teleportIncrement = 0.4 -- studs per step
local teleportInterval = 0.002 -- seconds per step
local instantTeleportRadius = 50 -- studs

local fruitsList = {
    "Fruit", "Rocket Fruit", "Spin Fruit", "Chop Fruit", "Spring Fruit", "Bomb Fruit", "Spike Fruit",
    "Smoke Fruit", "Blade Fruit", "Sand Fruit", "Ice Fruit", "Dark Fruit", "Diamond Fruit", "Light Fruit",
    "Rubber Fruit", "Barrier Fruit", "Magma Fruit", "Phoenix Fruit", "Love Fruit", "Spider Fruit",
    "Sound Fruit", "Buddha Fruit", "Quake Fruit", "Gravity Fruit", "Control Fruit", "T-Rex Fruit",
    "Mammoth Fruit", "Spirit Fruit", "Venom Fruit", "Shadow Fruit", "Rumble Fruit", "Portal Fruit",
    "Blizzard Fruit", "Dragon Fruit", "Leopard Fruit", "Dough Fruit", "Dragon (West) Fruit",
    "Dragon (East) Fruit", "Kitsune Fruit", "Gas Fruit", "Yeti Fruit"
}

-- Function to join Marines
local function JoinTeam()
    if plr.Team ~= game.Teams.Marines then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Marines")
        repeat task.wait(1) until plr.Team == game.Teams.Marines
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
        end
    end
    return nearestFruit, nearestDistance
end

-- Move Towards Nearest Fruit
local function MoveTowardsFruit()
    while task.wait(teleportInterval) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            local nearestFruit, distance = GetNearestFruit()
            if nearestFruit and distance > 1 then -- Avoid unnecessary movement
                if distance <= instantTeleportRadius then
                    hrp.CFrame = nearestFruit.Handle.CFrame -- Instant teleport if within radius
                else
                    local direction = (nearestFruit.Handle.Position - hrp.Position).unit
                    local stepSize = math.min(teleportSpeed * teleportInterval, distance)
                    hrp.CFrame = hrp.CFrame + direction * stepSize
                end
            end
        end
    end
end

-- Server Hop Function
local function ServerHop()
    local success, response = pcall(function()
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        local validServers = {}
        for _, server in ipairs(servers.data) do
            if server.id ~= game.JobId then
                table.insert(validServers, server.id)
            end
        end
        if #validServers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, validServers[math.random(1, #validServers)])
        end
    end)
    if not success then warn("Server hop failed: " .. tostring(response)) end
end

-- Start Processes
JoinTeam()
task.spawn(MoveTowardsFruit)

plr.CharacterAdded:Connect(function()
    task.wait(1)
    JoinTeam()
    task.spawn(MoveTowardsFruit)
end)
