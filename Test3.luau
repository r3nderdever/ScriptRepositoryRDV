--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

--// Variables
local plr = Players.LocalPlayer
local webhookURL = "https://discord.com/api/webhooks/1332763994758316172/ya0sKT_D0t-iGSxH9pGyQOtYdIIa1Ekq1DrS3zbCN68MbFlw_fl1A64kRRYWCGcIZNV3"

local serverHopDelay = 0.3 -- Server hop retry delay
local teleportSpeed = 200 -- Studs per second
local teleportInterval = 0.002 -- Smooth movement
local instantTeleportRadius = 40 -- Studs
local fruitDetectionTimer = 5 -- Time before server hop
local lastFruitDetected = tick()

--// Create UI Panel
local function CreateUI()
    local screenGui = Instance.new("ScreenGui", game.CoreGui)
    screenGui.Name = "FruitFinderUI"

    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 250, 0, 140)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 2
    frame.Active = true
    frame.Draggable = true

    local uiCorner = Instance.new("UICorner", frame)
    uiCorner.CornerRadius = UDim.new(0, 10)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "🍍 Fruit Finder"
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18

    local info = Instance.new("TextLabel", frame)
    info.Size = UDim2.new(1, -10, 0, 90)
    info.Position = UDim2.new(0, 5, 0, 40)
    info.BackgroundTransparency = 1
    info.TextColor3 = Color3.fromRGB(255, 255, 255)
    info.Font = Enum.Font.Gotham
    info.TextSize = 14
    info.TextWrapped = true
    info.Text = "🌍 Server: N/A\n🕒 Timer: N/A\n🥭 Last Fruit: N/A\n🔄 Status: Searching..."

    return info
end
local uiInfo = CreateUI()

--// Send Webhook Notification
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
            },
        }}
    }
    pcall(function()
        HttpService:PostAsync(webhookURL, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson, false)
    end)
end

--// Find & Collect Fruit
local function CollectFruit(item)
    if item:IsA("Tool") and item.Name:find("Fruit") then
        local fruitName = item:GetAttribute("OriginalName") or item.Name
        print("[🍍] Found Fruit: " .. fruitName)

        -- Update UI
        uiInfo.Text = "🌍 Server: " .. game.JobId .. "\n🕒 Timer: Searching...\n🥭 Last Fruit: " .. fruitName .. "\n🔄 Status: Collecting..."

        -- Move to fruit
        plr.Character.HumanoidRootPart.CFrame = item.Handle.CFrame
        task.wait(1)

        -- Store fruit
        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", fruitName, item)

        -- Send webhook
        SendWebhookNotification(fruitName)

        -- Reset fruit detection timer
        lastFruitDetected = tick()
    end
end

--// Get Nearest Fruit
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

--// Move Towards Nearest Fruit
local function MoveTowardsFruit()
    while task.wait(teleportInterval) do
        local nearestFruit = GetNearestFruit()
        if nearestFruit then
            lastFruitDetected = tick()

            -- Instant teleport for close fruits
            if (plr.Character.HumanoidRootPart.Position - nearestFruit.Handle.Position).Magnitude <= instantTeleportRadius then
                plr.Character.HumanoidRootPart.CFrame = nearestFruit.Handle.CFrame
                CollectFruit(nearestFruit)
            end
        end
    end
end

--// Smart Server Hop (5-11 Players)
local function ServerHop()
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100")).data
    local validServers = {}

    for _, server in ipairs(servers) do
        if server.playing >= 5 and server.playing <= 11 and server.id ~= game.JobId then
            table.insert(validServers, server.id)
        end
    end

    if #validServers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, validServers[math.random(1, #validServers)])
    else
        task.wait(serverHopDelay)
        ServerHop()
    end
end

--// Start Systems
task.spawn(MoveTowardsFruit)

--// Timer to Check for Fruit
task.spawn(function()
    while task.wait(0.3) do
        if tick() - lastFruitDetected >= fruitDetectionTimer then
            uiInfo.Text = "🌍 Server: " .. game.JobId .. "\n🔄 Status: Server Hopping..."
            ServerHop()
        end
    end
end)
