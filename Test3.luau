--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

--// Variables
local plr = Players.LocalPlayer
local serverHopDelay = 1 -- Delay between server hop retries (seconds)
local serverHopTimer = 4 -- Time until server hop when no fruit is found
local teleportSpeed = 150 -- studs per second
local teleportInterval = 0.002 -- seconds per step
local instantTeleportRadius = 50 -- studs
local lastFruitTime = tick()
local running = true

local fruitsList = {
    "Fruit", "Rocket Fruit", "Spin Fruit", "Chop Fruit", "Spring Fruit", "Bomb Fruit", "Spike Fruit",
    "Smoke Fruit", "Blade Fruit", "Sand Fruit", "Ice Fruit", "Dark Fruit", "Diamond Fruit", "Light Fruit",
    "Rubber Fruit", "Barrier Fruit", "Magma Fruit", "Phoenix Fruit", "Love Fruit", "Spider Fruit",
    "Sound Fruit", "Buddha Fruit", "Quake Fruit", "Gravity Fruit", "Control Fruit", "T-Rex Fruit",
    "Mammoth Fruit", "Spirit Fruit", "Venom Fruit", "Shadow Fruit", "Rumble Fruit", "Portal Fruit",
    "Blizzard Fruit", "Dragon Fruit", "Leopard Fruit", "Dough Fruit", "Dragon (West) Fruit",
    "Dragon (East) Fruit", "Kitsune Fruit", "Gas Fruit", "Yeti Fruit"
}

--// UI Setup
local function CreateUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = plr:FindFirstChild("PlayerGui") or plr:WaitForChild("PlayerGui")

    local infoLabel = Instance.new("TextLabel", screenGui)
    infoLabel.Size = UDim2.new(0.5, 0, 0.05, 0)
    infoLabel.Position = UDim2.new(0.25, 0, 0.9, 0)
    infoLabel.BackgroundTransparency = 0.5
    infoLabel.BackgroundColor3 = Color3.new(0, 0, 0)
    infoLabel.TextColor3 = Color3.new(1, 1, 1)
    infoLabel.TextScaled = true
    infoLabel.Text = "Searching for fruit..."
    
    return infoLabel
end

local infoLabel = CreateUI()

--// Function to Join Marines Team
local function JoinTeam()
    if plr.Team ~= game.Teams.Marines then
        local success, _ = pcall(function()
            return ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Marines")
        end)
        if success then
            repeat task.wait(1) until plr.Team == game.Teams.Marines
        end
    end
end

--// Detect Nearest Fruit
local function GetNearestFruit()
    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, math.huge end
    
    local nearestFruit, nearestDistance = nil, math.huge
    for _, fruitName in ipairs(fruitsList) do
        local fruit = Workspace:FindFirstChild(fruitName)
        if fruit and fruit:FindFirstChild("Handle") then
            local distance = (hrp.Position - fruit.Handle.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestFruit = fruit
            end
        end
    end
    return nearestFruit, nearestDistance
end

--// Move Towards Nearest Fruit
local function MoveTowardsFruit()
    while running and task.wait(teleportInterval) do
        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local nearestFruit, distance = GetNearestFruit()
        if nearestFruit then
            lastFruitTime = tick()
            infoLabel.Text = "Found: " .. nearestFruit.Name .. " | Distance: " .. math.floor(distance)

            if distance <= instantTeleportRadius then
                hrp.CFrame = nearestFruit.Handle.CFrame -- Instant teleport
            else
                local direction = (nearestFruit.Handle.Position - hrp.Position).unit
                local stepSize = math.min(teleportSpeed * teleportInterval, distance)
                hrp.CFrame = hrp.CFrame + direction * stepSize
            end
        else
            local timeSinceLastFruit = tick() - lastFruitTime
            infoLabel.Text = "No fruit found. Server hopping in " .. string.format("%.1f", math.max(0, serverHopTimer - timeSinceLastFruit)) .. "s"
            if timeSinceLastFruit >= serverHopTimer then
                ServerHop()
            end
        end
    end
end

--// Server Hop Function (Infinite Retries with Delay)
local function ServerHop()
    while running do
        local success, response = pcall(function()
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if success and response and response.data then
            local availableServers = {}

            -- Filter valid servers
            for _, server in ipairs(response.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    table.insert(availableServers, server.id)
                end
            end

            -- If there are valid servers, teleport
            if #availableServers > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, availableServers[math.random(#availableServers)])
                return -- Exit function after teleport
            else
                warn("No available servers found, retrying in " .. serverHopDelay .. "s...")
            end
        else
            warn("Failed to get server list, retrying in " .. serverHopDelay .. "s...")
        end

        task.wait(serverHopDelay) -- Delay before retrying
    end
end

--// Start Processes
task.spawn(function()
    JoinTeam()
    MoveTowardsFruit()
end)

plr.CharacterAdded:Connect(function()
    task.wait(1)
    JoinTeam()
    task.spawn(MoveTowardsFruit)
end)

-- Auto-recovery for script crashes
Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == plr then
        running = false -- Stop all loops if player leaves
    end
end)
