--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

--// Variables
local plr = Players.LocalPlayer
local webhookURL = "https://discord.com/api/webhooks/1332763994758316172/ya0sKT_D0t-iGSxH9pGyQOtYdIIa1Ekq1DrS3zbCN68MbFlw_fl1A64kRRYWCGcIZNV3"

local serverHopDelay = 0.3 -- Delay between server hop attempts
local fruitDetectionTimer = 5 -- Time before server hop if no fruit is found
local lastFruitDetected = tick()

--// Function to send webhook notifications
local function SendWebhookNotification(fruitName)
    local data = {
        ["username"] = "Fruit Finder",
        ["embeds"] = {{
            ["title"] = "🍍 Fruit Found!",
            ["description"] = "**A new fruit has been found!**",
            ["color"] = 16755200,
            ["fields"] = {
                {["name"] = "📝 Fruit Name", ["value"] = "**" .. fruitName .. "**", ["inline"] = true},
                {["name"] = "👤 Player", ["value"] = "**" .. plr.Name .. "**", ["inline"] = true},
                {["name"] = "🌍 Server ID", ["value"] = "```" .. game.JobId .. "```", ["inline"] = false},
                {["name"] = "⏳ Time Found", ["value"] = "```" .. os.date("%Y-%m-%d %H:%M:%S") .. "```", ["inline"] = false}
            }
        }}
    }

    task.spawn(function()
        local success, response = pcall(function()
            return HttpService:PostAsync(webhookURL, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson, false)
        end)
        
        if not success then
            warn("[⚠️ Webhook Failed] Retrying in 3 seconds...")
            task.wait(3)
            SendWebhookNotification(fruitName) -- Retry
        end
    end)
end

--// Constantly store fruits
local function StoreFruits()
    while true do
        task.wait(1)
        pcall(function()
            for _, tool in ipairs(plr.Backpack:GetChildren()) do
                if tool:IsA("Tool") and tool.Name:find("Fruit") then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", tool:GetAttribute("OriginalName") or tool.Name, tool)
                end
            end
        end)
    end
end

--// Get nearest fruit
local function GetNearestFruit()
    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    for _, fruit in ipairs(Workspace:GetChildren()) do
        if fruit:IsA("Tool") and fruit.Name:find("Fruit") then
            return fruit
        end
    end
    return nil
end

--// Move towards and collect fruits
local function CollectFruits()
    while task.wait(0.5) do
        pcall(function()
            local nearestFruit = GetNearestFruit()
            if nearestFruit then
                lastFruitDetected = tick()

                -- Teleport to fruit
                plr.Character.HumanoidRootPart.CFrame = nearestFruit.Handle.CFrame
                task.wait(1)

                -- Store fruit
                local fruitName = nearestFruit:GetAttribute("OriginalName") or nearestFruit.Name
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", fruitName, nearestFruit)

                -- Send webhook
                SendWebhookNotification(fruitName)
            end
        end)
    end
end

--// Multiple Server Hop Systems
local function ServerHop()
    task.spawn(function()
        while true do
            task.wait(serverHopDelay)

            -- Fetch public servers
            local success, servers = pcall(function()
                return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"))
            end)

            if success and servers and servers.data then
                local validServers = {}

                for _, server in ipairs(servers.data) do
                    if server.playing >= 5 and server.playing <= 11 and server.id ~= game.JobId then
                        table.insert(validServers, server.id)
                    end
                end

                -- If valid servers found, teleport to a random one
                if #validServers > 0 then
                    local randomServer = validServers[math.random(1, #validServers)]
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer)
                    return
                end
            end

            -- Alternative method (force different server)
            task.wait(1)
            pcall(function()
                TeleportService:Teleport(game.PlaceId)
            end)
        end
    end)
end

--// Timer to check for fruit & server hop
task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            if tick() - lastFruitDetected >= fruitDetectionTimer then
                warn("[⚠️] No fruit detected! Server hopping...")
                ServerHop()
            end
        end)
    end
end)

--// Start all processes
task.spawn(StoreFruits)
task.spawn(CollectFruits)
ServerHop() -- Start server hopping loop
