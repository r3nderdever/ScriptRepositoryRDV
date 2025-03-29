--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local PhysicsService = game:GetService("PhysicsService")

--// Variables
local plr = Players.LocalPlayer
local serverHopDelay = 5 -- Delay between server hop retries (seconds)
local serverHopTimer = 4 -- Time until server hop when no fruit is found
local teleportSpeed = 178 -- Studs per second
local teleportInterval = 0.002 -- Seconds per step
local instantTeleportRadius = 50 -- Studs
local collisionRadius = 40 -- Players become solid within this range
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

--// Setup Collision Groups
PhysicsService:CreateCollisionGroup("NoCollide")
PhysicsService:CollisionGroupSetCollidable("NoCollide", "NoCollide", false)

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

--// Prevent Character from Being Pushed
local function PreventPush()
    local character = plr.Character
    if character then
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.AssemblyLinearVelocity = Vector3.zero -- Prevent being pushed
            end
        end
    end
end

--// Disable Gravity and Movement
local function DisableGravity()
    local humanoid = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    
    if humanoid then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) -- Prevent falling
        humanoid.PlatformStand = true -- Stops movement while teleporting
        humanoid.AutoRotate = false -- Prevents auto-rotation
    end

    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero -- Stops external forces
    end
end

--// Enable Gravity
local function EnableGravity()
    local humanoid = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        humanoid.PlatformStand = false
        humanoid.AutoRotate = true
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

            if distance <= instantTeleportRadius then
                hrp.CFrame = nearestFruit.Handle.CFrame -- Instant teleport
                EnableGravity()
            else
                DisableGravity()
                local direction = (nearestFruit.Handle.Position - hrp.Position).unit
                local stepSize = math.min(teleportSpeed * teleportInterval, distance)
                hrp.CFrame = hrp.CFrame + direction * stepSize
                PreventPush()
            end
        else
            if tick() - lastFruitTime >= serverHopTimer then
                ServerHop()
            end
        end
    end
end

--// 5 Different Server Hop Methods
local function ServerHop()
    local methods = {
        -- Primary API Method
        function()
            local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
            if servers and servers.data and #servers.data > 0 then
                local server = servers.data[math.random(1, #servers.data)]
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
            end
        end,

        -- Random Server Indexing
        function()
            local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=" .. math.random(50, 100)))
            if servers and servers.data and #servers.data > 0 then
                local server = servers.data[math.random(1, #servers.data)]
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
            end
        end,

        -- Filtered Server Selection (Avoid low player counts)
        function()
            local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"))
            local filtered = {}
            for _, s in ipairs(servers.data) do
                if s.playing and s.playing > 5 then
                    table.insert(filtered, s)
                end
            end
            if #filtered > 0 then
                local server = filtered[math.random(1, #filtered)]
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
            end
        end,

        -- Sort By Random Criteria
        function()
            local sort = {"Asc", "Desc"}
            local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=" .. sort[math.random(1, 2)] .. "&limit=100"))
            if servers and servers.data and #servers.data > 0 then
                local server = servers.data[math.random(1, #servers.data)]
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
            end
        end
    }

    local method = methods[math.random(1, #methods)]
    method()
end

--// Start Processes
task.spawn(MoveTowardsFruit)
plr.CharacterAdded:Connect(function() task.wait(1) MoveTowardsFruit() end)
