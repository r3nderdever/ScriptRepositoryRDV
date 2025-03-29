repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local plr = Players.LocalPlayer
local Config = { NoFruitTime = 3 }
local VisitedServers = {}

-- **🔵 Auto Join Marines**
task.spawn(function()
    while plr.Team ~= game.Teams.Marines do
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("SetTeam", "Marines")
        task.wait(1)
    end
end)

-- **🍏 UI Setup**
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local UIFrame = Instance.new("Frame", ScreenGui)
local UILabel = Instance.new("TextLabel", UIFrame)
local UICorner = Instance.new("UICorner", UIFrame)

ScreenGui.ResetOnSpawn = false
UIFrame.Size = UDim2.new(0, 260, 0, 60)
UIFrame.Position = UDim2.new(0.5, -130, 0.1, 0)
UIFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
UIFrame.BorderSizePixel = 2
UIFrame.BorderColor3 = Color3.fromRGB(255, 140, 0)
UICorner.CornerRadius = UDim.new(0, 10)

UILabel.Size = UDim2.new(1, -10, 1, -10)
UILabel.Position = UDim2.new(0, 5, 0, 5)
UILabel.BackgroundTransparency = 1
UILabel.TextColor3 = Color3.fromRGB(255, 255, 255)
UILabel.Font = Enum.Font.Cartoon
UILabel.TextXAlignment = Enum.TextXAlignment.Left
UILabel.TextScaled = true
UILabel.Text = "🍏 Fruit: ??? | 📍 Distance: ??? | ⏳ Hop: 3s"

-- **🍏 Detect & Teleport to Fruits**
task.spawn(function()
    while task.wait(0.03) do
        if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then continue end
        local root = plr.Character.HumanoidRootPart
        root.AssemblyLinearVelocity = Vector3.zero
        root.CanCollide = false

        local closestFruit, closestDistance = nil, math.huge

        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Tool") and not v.Parent:IsA("Player") and v:FindFirstChild("Handle") then
                local fruitPos = v.Handle.Position
                local distance = (root.Position - fruitPos).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestFruit = v
                end
            end
        end

        if closestFruit then
            local fruitPos = closestFruit.Handle.Position
            if closestDistance <= 40 then
                root.CFrame = CFrame.new(fruitPos)
            else
                local direction = (fruitPos - root.Position).Unit
                root.CFrame = root.CFrame + direction * 15
            end
            Config.NoFruitTime = 3
            UILabel.Text = "🍏 Fruit: " .. closestFruit.Name .. " | 📍 Distance: " .. math.floor(closestDistance) .. "m | ⏳ Hop: 3s"
        else
            Config.NoFruitTime = math.max(0, Config.NoFruitTime - 0.03)
            UILabel.Text = "🍏 Fruit: ??? | 📍 Distance: ??? | ⏳ Hop: " .. string.format("%.1f", Config.NoFruitTime) .. "s"
        end
    end
end)

-- **🌍 Server Hop System**
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

local function TPReturner()
    local Site
    if foundAnything == "" then
        Site = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100"))
    else
        Site = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. foundAnything))
    end

    local ID = ""
    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
        foundAnything = Site.nextPageCursor
    end

    local num = 0
    for _, v in pairs(Site.data) do
        local Possible = true
        ID = tostring(v.id)
        if tonumber(v.maxPlayers) > tonumber(v.playing) then
            for _, Existing in pairs(AllIDs) do
                if num ~= 0 then
                    if ID == tostring(Existing) then
                        Possible = false
                    end
                else
                    if tonumber(actualHour) ~= tonumber(Existing) then
                        local delFile = pcall(function()
                            delfile("NotSameServers.json")
                            AllIDs = {}
                            table.insert(AllIDs, actualHour)
                        end)
                    end
                end
                num = num + 1
            end
            if Possible then
                table.insert(AllIDs, ID)
                pcall(function()
                    writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
                    task.wait()
                    TeleportService:TeleportToPlaceInstance(PlaceID, ID, plr)
                end)
                task.wait(4)
            end
        end
    end
end

local function Teleport()
    while task.wait() do
        pcall(function()
            TPReturner()
            if foundAnything ~= "" then
                TPReturner()
            end
        end)
    end
end

-- **🔄 Constantly Check for Server Hop**
task.spawn(function()
    while task.wait(0.5) do
        if Config.NoFruitTime <= 0 then
            Teleport()
        end
    end
end)

-- **🛠️ Auto Store Fruits**
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            for _, fr in ipairs(plr.Backpack:GetChildren()) do
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", fr:GetAttribute("OriginalName"), fr)
            end
            for _, fr in ipairs(plr.Character:GetChildren()) do
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", fr:GetAttribute("OriginalName"), fr)
            end
        end)
    end
end)
