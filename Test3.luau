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

--// Ultimate Server Hop System (Never Rejoins Same Server)
local function ServerHop()
    task.spawn(function()
        local PlaceID = game.PlaceId
        local AllIDs = {}
        local foundAnything = ""
        local actualHour = os.date("!*t").hour
        local File = pcall(function()
            AllIDs = HttpService:JSONDecode(readfile("NotSameServers.json"))
        end)
        if not File then
            table.insert(AllIDs, actualHour)
            writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
        end

        function TPReturner()
            local Site
            if foundAnything == "" then
                Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
            else
                Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
            end
            for _, v in pairs(Site.data) do
                local ID = tostring(v.id)
                local Possible = true

                if v.playing >= 5 and v.playing <= 11 then
                    for _, Existing in pairs(AllIDs) do
                        if ID == tostring(Existing) then
                            Possible = false
                        end
                    end
                    if Possible then
                        table.insert(AllIDs, ID)
                        writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
                        TeleportService:TeleportToPlaceInstance(PlaceID, ID, plr)
                        return
                    end
                end
            end
        end

        -- Retry until a new server is found
        while task.wait(0.3) do
            pcall(function()
                TPReturner()
                if foundAnything ~= "" then
                    TPReturner()
                end
            end)
        end
    end)
end

--// Timer to check for fruit & trigger server hop
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
