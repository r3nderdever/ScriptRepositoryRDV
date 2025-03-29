repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

local Players, ReplicatedStorage, TweenService, HttpService, TeleportService = 
    game:GetService("Players"), 
    game:GetService("ReplicatedStorage"),
    game:GetService("TweenService"),
    game:GetService("HttpService"),
    game:GetService("TeleportService")

local plr = Players.LocalPlayer
local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local lastServerHop = tick()

-- Webhook Setup
local WebhookURL = "https://discord.com/api/webhooks/1332763994758316172/ya0sKT_D0t-iGSxH9pGyQOtYdIIa1Ekq1DrS3zbCN68MbFlw_fl1A64kRRYWCGcIZNV3"

-- Load stored server IDs
local File = pcall(function()
    AllIDs = HttpService:JSONDecode(readfile("NotSameServers.json"))
end)
if not File then
    table.insert(AllIDs, actualHour)
    writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
end

-- Function to hop servers
local function ServerHop()
    local Site = foundAnything == "" 
        and HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
        or HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))

    local ID = ""
    if Site.nextPageCursor then foundAnything = Site.nextPageCursor end
    for _, v in pairs(Site.data) do
        if v.playing >= 5 and v.playing <= 11 and v.id then
            ID = tostring(v.id)
            if not table.find(AllIDs, ID) then
                table.insert(AllIDs, ID)
                pcall(function()
                    writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
                    task.wait(0.3)
                    TeleportService:TeleportToPlaceInstance(PlaceID, ID, plr)
                end)
                return
            end
        end
    end
end

-- Function to send a Discord webhook
local function SendWebhook(fruitName)
    local data = {
        ["content"] = "**Fruit Found!**",
        ["embeds"] = {{
            ["title"] = "🍇 Fruit Notification",
            ["description"] = "**Fruit:** " .. fruitName .. "\n**Found By:** " .. plr.Name .. "\n**Time:** " .. os.date("%Y-%m-%d %H:%M:%S"),
            ["color"] = 16711680
        }}
    }
    HttpService:PostAsync(WebhookURL, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
end

-- Function to store fruit
local function StoreFruit(tool)
    if tool:IsA("Tool") and tool.Name:find("Fruit") then
        task.spawn(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", tool:GetAttribute("OriginalName"), tool)
        end)
    end
end

-- Fruit collection function
local function CollectFruit()
    local foundFruit = false
    local collected = false

    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Tool") and v.Name:find("fruit") then
            foundFruit = true
            plr.Character.HumanoidRootPart.CFrame = v.Handle.CFrame
            task.wait(0.5)
            if not v:IsDescendantOf(workspace) then
                SendWebhook(v.Name)
                StoreFruit(v)
                collected = true
            end
        end
    end

    return collected
end

-- Main loop for finding fruits and server hopping
task.spawn(function()
    while task.wait() do
        pcall(function()
            if CollectFruit() then
                lastServerHop = tick()  -- Reset hop timer
            elseif tick() - lastServerHop > 5 then
                ServerHop()
            end
        end)
    end
end)

-- Auto-store feature
task.spawn(function()
    while task.wait() do
        pcall(function()
            for _, item in ipairs(plr.Backpack:GetChildren()) do
                StoreFruit(item)
            end
            for _, item in ipairs(plr.Character:GetChildren()) do
                StoreFruit(item)
            end
        end)
    end
end)

plr.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(StoreFruit)
end)

if plr.Character then
    plr.Character.ChildAdded:Connect(StoreFruit)
end)
