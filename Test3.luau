--[[
    WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]

repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

local Players, ReplicatedStorage, TweenService, HttpService, TeleportService = 
    game:GetService("Players"), 
    game:GetService("ReplicatedStorage"),
    game:GetService("TweenService"),
    game:GetService("HttpService"),
    game:GetService("TeleportService")

local plr = Players.LocalPlayer
local Config = {
    AutoFruit = true,
    AutoStoreFruit = true,
    FruitLog = {}
}

-- Function to load stored fruit log
local function LoadFruitLog()
    if isfile("fruitlog.json") then
        Config.FruitLog = HttpService:JSONDecode(readfile("fruitlog.json"))
    end
end

-- Function to save fruit log
local function SaveFruitLog()
    writefile("fruitlog.json", HttpService:JSONEncode(Config.FruitLog))
end

-- Function to log collected fruits
local function LogFruit(fruitName)
    table.insert(Config.FruitLog, {
        fruit = fruitName,
        time = os.date("%Y-%m-%d %H:%M:%S")
    })
    SaveFruitLog()
end

-- Function to find a base part inside a model
local function FindBasePart(model)
    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("BasePart") then return v end
    end
end

-- Function to collect fruit
local function CollectItem(item)
    if not item then return false end

    if item:IsA("Tool") then
        local handle = item:FindFirstChild("Handle")
        if handle then
            handle.CFrame = plr.Character.HumanoidRootPart.CFrame
            if not item:IsDescendantOf(workspace) then
                LogFruit(item.Name)
                return true
            end
        end
    elseif item:IsA("Model") and (item.Name == "Fruit" or item.Name == "fruit") then
        local basePart = FindBasePart(item)
        if basePart then
            local startTime = tick()
            repeat
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(basePart.Position + Vector3.new(0, 3, 0))
                end
                task.wait()
                if not item:IsDescendantOf(workspace) then
                    LogFruit("Model Fruit")
                    return true
                end
            until tick() - startTime > 10
        end
    end
    return false
end

-- Function to create UI
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FruitFinderUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")

    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size = UDim2.new(0, 300, 0, 150)
    Frame.Position = UDim2.new(0.5, -150, 0.1, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.Active = true
    Frame.Draggable = true

    local Title = Instance.new("TextLabel", Frame)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Title.Text = "Fruit Finder"
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)

    local ToggleButton = Instance.new("TextButton", Frame)
    ToggleButton.Size = UDim2.new(1, 0, 0, 30)
    ToggleButton.Position = UDim2.new(0, 0, 0, 35)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ToggleButton.Text = "Auto Collect: ON"
    ToggleButton.Font = Enum.Font.Gotham
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)

    local ServerHopButton = Instance.new("TextButton", Frame)
    ServerHopButton.Size = UDim2.new(1, 0, 0, 30)
    ServerHopButton.Position = UDim2.new(0, 0, 0, 70)
    ServerHopButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ServerHopButton.Text = "Hop Server"
    ServerHopButton.Font = Enum.Font.Gotham
    ServerHopButton.TextColor3 = Color3.fromRGB(255, 255, 255)

    local CloseButton = Instance.new("TextButton", Frame)
    CloseButton.Size = UDim2.new(1, 0, 0, 30)
    CloseButton.Position = UDim2.new(0, 0, 0, 110)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.Text = "Close"
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)

    ToggleButton.MouseButton1Click:Connect(function()
        Config.AutoFruit = not Config.AutoFruit
        ToggleButton.Text = Config.AutoFruit and "Auto Collect: ON" or "Auto Collect: OFF"
    end)

    ServerHopButton.MouseButton1Click:Connect(function()
        Teleport()
    end)

    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
end

-- Server Hop Function
local PlaceID = game.PlaceId
local AllIDs = {}
local actualHour = os.date("!*t").hour
local File = pcall(function()
    AllIDs = HttpService:JSONDecode(readfile("NotSameServers.json"))
end)
if not File then
    table.insert(AllIDs, actualHour)
    writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
end

function TPReturner()
    local Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
    for _, v in pairs(Site.data) do
        local ID = tostring(v.id)
        if tonumber(v.maxPlayers) > tonumber(v.playing) and not table.find(AllIDs, ID) then
            table.insert(AllIDs, ID)
            writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
            TeleportService:TeleportToPlaceInstance(PlaceID, ID, plr)
            wait(4)
        end
    end
end

function Teleport()
    while task.wait() do
        pcall(TPReturner)
    end
end

-- Start fruit finder
task.spawn(function()
    while task.wait() do
        if Config.AutoFruit then
            pcall(function()
                for _, v in ipairs(workspace:GetChildren()) do
                    if v:IsA("Tool") and v.Name:find("fruit") then
                        CollectItem(v)
                    elseif v:IsA("Model") and (v.Name == "Fruit" or v.Name == "fruit") then
                        CollectItem(v)
                    end
                end
            end)
        end
    end
end)

-- Start UI
CreateUI()
