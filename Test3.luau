repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer
task.wait(3) -- Wait 3 seconds after loading

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local plr = Players.LocalPlayer

-- List of fruits to target
local TargetFruits = {
    "Fruit ", "Rocket Fruit", "Spin Fruit", "Ghost Fruit", "Spring Fruit", "Bomb Fruit", "Spike Fruit",
    "Smoke Fruit", "Blade Fruit", "Sand Fruit", "Ice Fruit", "Dark Fruit", "Diamond Fruit", "Light Fruit",
    "Rubber Fruit", "Barrier Fruit", "Magma Fruit", "Phoenix Fruit", "Love Fruit", "Spider Fruit",
    "Sound Fruit", "Buddha Fruit", "Quake Fruit", "Gravity Fruit", "Control Fruit", "T-Rex Fruit",
    "Mammoth Fruit", "Spirit Fruit", "Venom Fruit", "Shadow Fruit", "Rumble Fruit", "Portal Fruit",
    "Blizzard Fruit", "Dragon Fruit", "Leopard Fruit", "Dough Fruit", "Dragon (West) Fruit",
    "Dragon (East) Fruit", "Kitsune Fruit", "Gas Fruit", "Yeti Fruit"
}

-- Auto-Join Marines Team
local function JoinMarines()
    if plr.Team ~= game.Teams.Marines and plr.Team ~= game.Teams.Pirates then
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("SetTeam", "Marines")
    end
end
JoinMarines()

-- Function to store fruit
local function StoreFruit(tool)
    if tool:IsA("Tool") and table.find(TargetFruits, tool.Name) then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", tool:GetAttribute("OriginalName"), tool)
    end
end

-- Function to check and store all fruits in backpack & character
local function AutoStoreFruits()
    pcall(function()
        for _, fruit in ipairs(plr.Backpack:GetChildren()) do
            StoreFruit(fruit)
        end
        if plr.Character then
            for _, fruit in ipairs(plr.Character:GetChildren()) do
                StoreFruit(fruit)
            end
        end
    end)
end

-- Run AutoStoreFruits every 0.3 seconds
task.spawn(function()
    while task.wait(0.3) do
        AutoStoreFruits()
    end
end)

-- Store fruits if new items are added to character
plr.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(StoreFruit)
end)

if plr.Character then
    plr.Character.ChildAdded:Connect(StoreFruit)
end

-- UI Setup for Fruit Finder
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local MainFrame = Instance.new("Frame", ScreenGui)
    local StatusLabel = Instance.new("TextLabel", MainFrame)

    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    MainFrame.Position = UDim2.new(0.8, -150, 0.5, -75)
    MainFrame.Size = UDim2.new(0, 300, 0, 50)
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Size = UDim2.new(1, 0, 1, 0)
    StatusLabel.Font = Enum.Font.GothamMedium
    StatusLabel.Text = "Searching for Fruits..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusLabel.TextSize = 16
    StatusLabel.Parent = MainFrame

    return StatusLabel
end

local StatusLabel = CreateUI()

-- Find the nearest targeted fruit
local function FindNearestFruit()
    local nearestFruit, nearestDistance
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Tool") and table.find(TargetFruits, v.Name) then
            local distance = (plr.Character.HumanoidRootPart.Position - v.Handle.Position).magnitude
            if not nearestFruit or distance < nearestDistance then
                nearestFruit, nearestDistance = v, distance
            end
        end
    end
    return nearestFruit, nearestDistance
end

-- Server Hop Function
local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local Deleted = false

local File = pcall(function()
    AllIDs = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
end)

if not File then
    table.insert(AllIDs, actualHour)
    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
end

function TPReturner()
    local Site
    if foundAnything == "" then
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
    else
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
    end

    local ID = ""
    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
        foundAnything = Site.nextPageCursor
    end

    local num = 0
    for i, v in pairs(Site.data) do
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
                wait()
                pcall(function()
                    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                    wait()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
                end)
                wait(4)
            end
        end
    end
end

function Teleport()
    while wait() do
        pcall(function()
            TPReturner()
            if foundAnything ~= "" then
                TPReturner()
            end
        end)
    end
end

-- Fruit Collection Logic
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local fruit, distance = FindNearestFruit()
            if fruit then
                StatusLabel.Text = fruit.Name .. " - " .. math.floor(distance) .. "m"
                -- Move to fruit
                local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(fruit.Handle.Position + Vector3.new(0, 3, 0))
                end
            else
                StatusLabel.Text = "No fruit found... Server hopping soon."
                task.wait(2.5)
                Teleport() -- Call the improved server hop function
            end
        end)
    end
end)

print("✅ Final Script Loaded: Auto Fruit Store, Marines Join, Server Hop, & UI with Targeted Fruits")
