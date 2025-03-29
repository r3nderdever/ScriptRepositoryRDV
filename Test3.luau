repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")

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
    TeleportService:Teleport(PlaceID)
end

-- UI Setup (Restored Old UI Design)
local function CreateUI()
    local ui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local frame = Instance.new("Frame", ui)
    local title = Instance.new("TextLabel", frame)
    local button1 = Instance.new("TextButton", frame)
    local button2 = Instance.new("TextButton", frame)
    
    frame.Size = UDim2.new(0, 280, 0, 160)
    frame.Position = UDim2.new(0.7, -140, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "🍏 Fruit Finder UI"
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(255, 255, 255)

    button1.Size = UDim2.new(1, -10, 0, 40)
    button1.Position = UDim2.new(0, 5, 0, 40)
    button1.Text = "Toggle Auto Fruit"
    button1.Font = Enum.Font.Gotham
    button1.TextSize = 16
    button1.TextColor3 = Color3.fromRGB(255, 255, 255)
    button1.BackgroundColor3 = Color3.fromRGB(50, 50, 60)

    button2.Size = UDim2.new(1, -10, 0, 40)
    button2.Position = UDim2.new(0, 5, 0, 90)
    button2.Text = "Server Hop"
    button2.Font = Enum.Font.Gotham
    button2.TextSize = 16
    button2.TextColor3 = Color3.fromRGB(255, 255, 255)
    button2.BackgroundColor3 = Color3.fromRGB(50, 50, 60)

    button1.MouseButton1Click:Connect(function()
        Config.AutoFruit = not Config.AutoFruit
        button1.Text = "Auto Fruit: " .. (Config.AutoFruit and "ON" or "OFF")
    end)

    button2.MouseButton1Click:Connect(ServerHop)

    -- Make UI draggable
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function updateInput(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateInput(input)
        end
    end)

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

                if not fruitFound and tick() - lastServerHop >= 5 then
                    lastServerHop = tick()
                    task.spawn(ServerHop)
                end
            end)
        end
    end
end

task.spawn(MainLoop)

plr.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(StoreFruit)
end)

if plr.Character then
    plr.Character.ChildAdded:Connect(StoreFruit)
end

print("🔥 Script Loaded Successfully! 🔥")
