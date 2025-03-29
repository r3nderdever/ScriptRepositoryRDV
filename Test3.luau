repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local plr = Players.LocalPlayer
local webhookURL = "https://discord.com/api/webhooks/1332763994758316172/ya0sKT_D0t-iGSxH9pGyQOtYdIIa1Ekq1DrS3zbCN68MbFlw_fl1A64kRRYWCGcIZNV3"

local Config = {
    AutoFruit = true,
    AutoStoreFruit = true,
    FruitLog = {}
}

-- Function to ensure player joins Marines team
local function JoinMarines()
    while plr.Team ~= game.Teams.Marines do
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("SetTeam", "Marines")
        task.wait(1) -- Retry every second until successful
    end
end

task.spawn(JoinMarines) -- Run Marines team join process in the background

-- Webhook function to send fruit finds to Discord
local function SendWebhook(fruitName)
    local payload = HttpService:JSONEncode({
        content = "**Fruit Found!** 🍏\n**Fruit:** " .. fruitName .. "\n**Player:** " .. plr.Name .. "\n**Time:** " .. os.date("%Y-%m-%d %H:%M:%S")
    })
    
    HttpService:PostAsync(webhookURL, payload, Enum.HttpContentType.ApplicationJson)
end

-- Function to collect fruit
local function CollectFruit(item)
    if not item then return false end
    
    if item:IsA("Tool") then
        local handle = item:FindFirstChild("Handle")
        if handle then
            handle.CFrame = plr.Character.HumanoidRootPart.CFrame
            task.wait(0.5)
            SendWebhook(item.Name) -- Send to webhook
            return true
        end
    elseif item:IsA("Model") and item.Name:lower() == "fruit" then
        local basePart = item:FindFirstChildOfClass("BasePart")
        if basePart then
            local startTime = tick()
            repeat
                plr.Character.HumanoidRootPart.CFrame = basePart.CFrame + Vector3.new(0, 3, 0)
                task.wait()
            until not item:IsDescendantOf(workspace) or tick() - startTime > 10
            SendWebhook("Unknown Fruit")
            return true
        end
    end
    
    return false
end

-- Auto store fruit function
local function StoreFruit(tool)
    if tool:IsA("Tool") and tool.Name:find("Fruit") then
        task.spawn(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", tool:GetAttribute("OriginalName"), tool)
        end)
    end
end

-- Server hop function (Optimized)
local function ServerHop()
    local PlaceID = game.PlaceId
    local AllIDs = {}
    local foundAnything = ""
    local actualHour = os.date("!*t").hour
    local Deleted = false
    local File = pcall(function()
        AllIDs = HttpService:JSONDecode(readfile("NotSameServers.json"))
    end)
    
    if not File then
        table.insert(AllIDs, actualHour)
        writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
    end

    local function TPReturner()
        local Site
        if foundAnything == "" then
            Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
        else
            Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
        end
        
        local ID = ""
        if Site.nextPageCursor then
            foundAnything = Site.nextPageCursor
        end

        for _, v in pairs(Site.data) do
            if v.playing >= 5 and v.playing <= 11 then
                local Possible = true
                ID = tostring(v.id)

                for _, Existing in pairs(AllIDs) do
                    if ID == tostring(Existing) then
                        Possible = false
                    end
                end

                if Possible then
                    table.insert(AllIDs, ID)
                    writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
                    TeleportService:TeleportToPlaceInstance(PlaceID, ID, plr)
                    task.wait(4)
                end
            end
        end
    end

    while true do
        pcall(TPReturner)
        task.wait(0.3)
    end
end

-- UI Setup
local function CreateUI()
    local ui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local frame = Instance.new("Frame", ui)
    local title = Instance.new("TextLabel", frame)
    
    frame.Size = UDim2.new(0, 250, 0, 120)
    frame.Position = UDim2.new(0.8, -250, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(255, 255, 255)

    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "🌍 Fruit Finder UI"
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(255, 255, 255)

    return frame
end

local function MainLoop()
    local lastServerHop = tick()
    local frame = CreateUI()

    while task.wait() do
        if Config.AutoFruit then
            pcall(function()
                local fruitFound = false
                
                for _, v in ipairs(workspace:GetChildren()) do
                    if v:IsA("Tool") and v.Name:find("fruit") then
                        fruitFound = true
                        CollectFruit(v)
                        break
                    end
                end
                
                if not fruitFound then
                    for _, v in ipairs(workspace:GetChildren()) do
                        if v:IsA("Model") and v.Name:lower() == "fruit" then
                            fruitFound = true
                            CollectFruit(v)
                            break
                        end
                    end
                end

                if not fruitFound and tick() - lastServerHop >= 5 then
                    lastServerHop = tick()
                    task.spawn(ServerHop)
                end
            end)
        end
    end
end

task.spawn(function()
    while task.wait() do
        if Config.AutoStoreFruit then
            pcall(function()
                for _, fr in ipairs(plr.Backpack:GetChildren()) do
                    StoreFruit(fr)
                end
                for _, fr in ipairs(plr.Character:GetChildren()) do
                    StoreFruit(fr)
                end
            end)
        end
    end
end)

plr.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(StoreFruit)
end)

if plr.Character then
    plr.Character.ChildAdded:Connect(StoreFruit)
end

print("🔥 Script Loaded Successfully! 🔥")
task.spawn(MainLoop)
