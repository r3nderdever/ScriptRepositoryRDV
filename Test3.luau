--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

--// Variables
local plr = Players.LocalPlayer
local webhookURL = "https://discord.com/api/webhooks/1332763994758316172/ya0sKT_D0t-iGSxH9pGyQOtYdIIa1Ekq1DrS3zbCN68MbFlw_fl1A64kRRYWCGcIZNV3"

local serverHopDelay = 5 -- Delay before retrying if no different server is found
local serverHopTimer = 4 -- Time until server hop when no fruit is found
local teleportSpeed = 178 -- Studs per second
local teleportInterval = 0.002 -- Seconds per step
local instantTeleportRadius = 50 -- Studs
local lastFruitTime = tick()

--// Send Webhook Notification
local function SendWebhookNotification(fruitName)
    local data = {
        ["username"] = "Fruit Finder",
        ["avatar_url"] = "https://static.wikia.nocookie.net/blox-fruits/images/d/d7/Game_Icon.png",
        ["embeds"] = {{
            ["title"] = "🍍 Fruit Found!",
            ["description"] = "**A new fruit has been found!**",
            ["color"] = 16755200, -- Orange color
            ["fields"] = {
                {["name"] = "📝 Fruit Name", ["value"] = "**" .. fruitName .. "**", ["inline"] = true},
                {["name"] = "👤 Player", ["value"] = "**" .. plr.Name .. "**", ["inline"] = true},
                {["name"] = "⏳ Time Found", ["value"] = "```" .. os.date("%Y-%m-%d %H:%M:%S") .. "```", ["inline"] = false}
            }
        }}
    }

    local success, response = pcall(function()
        HttpService:PostAsync(webhookURL, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson, false)
    end)

    if success then
        print("[✅] Webhook Sent: " .. fruitName)
    else
        warn("[❌] Webhook Failed!")
    end
end

--// Collect Fruit & Store Automatically
local function CollectFruit(item)
    if item:IsA("Tool") and item.Name:find("Fruit") then
        local fruitName = item:GetAttribute("OriginalName") or item.Name
        print("[🍍] Found Fruit: " .. fruitName)

        -- Teleport to fruit
        plr.Character.HumanoidRootPart.CFrame = item.Handle.CFrame
        task.wait(1)

        -- Store the fruit
        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", fruitName, item)

        -- Send Discord Webhook
        SendWebhookNotification(fruitName)
    end
end

--// Find Nearest Fruit
local function GetNearestFruit()
    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, math.huge end

    local nearestFruit, nearestDistance = nil, math.huge
    for _, fruit in ipairs(Workspace:GetChildren()) do
        if fruit:IsA("Tool") and fruit.Name:find("Fruit") then
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
    while task.wait(teleportInterval) do
        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local nearestFruit, distance = GetNearestFruit()
        if nearestFruit then
            lastFruitTime = tick()

            if distance <= instantTeleportRadius then
                hrp.CFrame = nearestFruit.Handle.CFrame -- Instant teleport
                CollectFruit(nearestFruit)
            else
                local direction = (nearestFruit.Handle.Position - hrp.Position).unit
                local stepSize = math.min(teleportSpeed * teleportInterval, distance)
                hrp.CFrame = hrp.CFrame + direction * stepSize
            end
        else
            if tick() - lastFruitTime >= serverHopTimer then
                ServerHop()
            end
        end
    end
end

--// Random Server Hop System
local function ServerHop()
    local currentServerId = game.JobId
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"))

    if servers and servers.data then
        for _, server in ipairs(servers.data) do
            if server.id ~= currentServerId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                return
            end
        end
    end
end

--// Server Hop Timer
local function CheckForServerHop()
    if tick() - lastFruitTime >= serverHopTimer then
        ServerHop()
    end
end

--// Start Fruit Collection & Server Hop System
task.spawn(MoveTowardsFruit)
task.spawn(function()
    while task.wait(serverHopDelay) do
        CheckForServerHop()
    end
end)

--// Detect Fruits in the Game
task.spawn(function()
    while task.wait(3) do
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Tool") and v.Name:find("Fruit") then
                CollectFruit(v)
            end
        end
    end
end)
