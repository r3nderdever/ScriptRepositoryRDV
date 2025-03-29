repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local plr = Players.LocalPlayer
local Config = { NoFruitTime = 3 }

-- **🔵 Auto Join Marines**
task.spawn(function()
    while plr.Team ~= game.Teams.Marines do
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("SetTeam", "Marines")
        task.wait(1)
    end
end)

-- **✅ Valid Fruits List**
local ValidFruits = {
    ["Rocket Fruit"] = true, ["Spin Fruit"] = true, ["Chop Fruit"] = true, ["Spring Fruit"] = true,
    ["Bomb Fruit"] = true, ["Spike Fruit"] = true, ["Smoke Fruit"] = true, ["Blade Fruit"] = true,
    ["Sand Fruit"] = true, ["Ice Fruit"] = true, ["Dark Fruit"] = true, ["Diamond Fruit"] = true,
    ["Light Fruit"] = true, ["Rubber Fruit"] = true, ["Barrier Fruit"] = true, ["Magma Fruit"] = true,
    ["Phoenix Fruit"] = true, ["Love Fruit"] = true, ["Spider Fruit"] = true, ["Sound Fruit"] = true,
    ["Buddha Fruit"] = true, ["Quake Fruit"] = true, ["Gravity Fruit"] = true, ["Control Fruit"] = true,
    ["T-Rex Fruit"] = true, ["Mammoth Fruit"] = true, ["Spirit Fruit"] = true, ["Venom Fruit"] = true,
    ["Shadow Fruit"] = true, ["Rumble Fruit"] = true, ["Portal Fruit"] = true, ["Blizzard Fruit"] = true,
    ["Dragon Fruit"] = true, ["Leopard Fruit"] = true, ["Dough Fruit"] = true, ["Dragon (West) Fruit"] = true,
    ["Dragon (East) Fruit"] = true, ["Kitsune Fruit"] = true, ["Gas Fruit"] = true, ["Yeti Fruit"] = true
}

-- **📜 UI Setup (Minimalist Design)**
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
            if v:IsA("Tool") and ValidFruits[v.Name] and not v.Parent:IsA("Player") then
                local fruitPos = v:FindFirstChild("Handle") and v.Handle.Position
                if fruitPos then
                    local distance = (root.Position - fruitPos).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestFruit = v
                    end
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

-- **🌍 Smarter Server Hop (Avoids Rejoining)**
local PlaceID = game.PlaceId
local AllIDs, foundAnything = {}, ""
local actualHour = os.date("!*t").hour
pcall(function()
    AllIDs = HttpService:JSONDecode(readfile("NotSameServers.json"))
end)
if not AllIDs or type(AllIDs) ~= "table" then
    AllIDs = {actualHour}
    writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
end

local function TPReturner()
    local Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100' .. (foundAnything ~= "" and "&cursor=" .. foundAnything or "")))
    if Site.nextPageCursor then foundAnything = Site.nextPageCursor end

    for _, v in ipairs(Site.data) do
        local ID = tostring(v.id)
        if v.playing >= 3 and v.playing < v.maxPlayers and not table.find(AllIDs, ID) then
            table.insert(AllIDs, ID)
            writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
            TeleportService:TeleportToPlaceInstance(PlaceID, ID, plr)
            task.wait(4)
        end
    end
end

task.spawn(function()
    while task.wait(0.2) do
        if Config.NoFruitTime <= 0 then
            TPReturner()
        end
    end
end)

-- **🛠️ Auto Store Fruits**
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            for _, fr in ipairs(plr.Backpack:GetChildren()) do
                if ValidFruits[fr.Name] then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", fr:GetAttribute("OriginalName"), fr)
                end
            end
            for _, fr in ipairs(plr.Character:GetChildren()) do
                if ValidFruits[fr.Name] then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", fr:GetAttribute("OriginalName"), fr)
                end
            end
        end)
    end
end)
