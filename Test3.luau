repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

local Players, ReplicatedStorage, HttpService, TeleportService, TweenService = 
    game:GetService("Players"), 
    game:GetService("ReplicatedStorage"),
    game:GetService("HttpService"),
    game:GetService("TeleportService"),
    game:GetService("TweenService")

local plr = Players.LocalPlayer
local Config = {
    AutoFruit = true,
    AutoEquip = true,
    FruitLog = {}
}

local lastServerHop = tick()
local serversTried = {}

-- Load and Save Fruit Log
local function LoadFruitLog()
    if isfile("fruitlog.json") then
        Config.FruitLog = HttpService:JSONDecode(readfile("fruitlog.json"))
    end
end

local function SaveFruitLog()
    writefile("fruitlog.json", HttpService:JSONEncode(Config.FruitLog))
end

local function LogFruit(fruitName)
    table.insert(Config.FruitLog, {
        fruit = fruitName,
        time = os.date("%Y-%m-%d %H:%M:%S")
    })
    SaveFruitLog()
end

-- Find BasePart for Models
local function FindBasePart(model)
    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("BasePart") then return v end
    end
end

-- Collect Fruit
local function CollectItem(item)
    if not item then return false end

    -- Ensure the player doesn't already have the fruit
    for _, heldItem in ipairs(plr.Backpack:GetChildren()) do
        if heldItem:IsA("Tool") and heldItem.Name == item.Name then
            return false
        end
    end

    for _, charItem in ipairs(plr.Character:GetChildren()) do
        if charItem:IsA("Tool") and charItem.Name == item.Name then
            return false
        end
    end

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
            until tick() - startTime > 5
        end
    end
    return false
end

-- Constantly Equip First Item
local function EquipFirstItem()
    while task.wait(0.5) do
        if Config.AutoEquip then
            pcall(function()
                if plr.Character then
                    local backpack = plr.Backpack:GetChildren()
                    if #backpack > 0 then
                        local firstItem = backpack[1]
                        if firstItem:IsA("Tool") then
                            plr.Character.Humanoid:EquipTool(firstItem)
                        end
                    end
                end
            end)
        end
    end
end

task.spawn(EquipFirstItem)

-- Create UI
local function CreateUI()
    local ui = {}
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local MainFrame = Instance.new("Frame", ScreenGui)
    local Title = Instance.new("TextLabel", MainFrame)
    local ToggleButton = Instance.new("TextButton", MainFrame)
    local StatusLabel = Instance.new("TextLabel", MainFrame)

    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    MainFrame.Position = UDim2.new(0.8, -150, 0.5, -150)
    MainFrame.Size = UDim2.new(0, 250, 0, 120)
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "Fruit Finder"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 22

    ToggleButton.BackgroundColor3 = Color3.fromRGB(65, 165, 65)
    ToggleButton.Position = UDim2.new(0.5, -75, 0, 40)
    ToggleButton.Size = UDim2.new(0, 150, 0, 30)
    ToggleButton.Font = Enum.Font.GothamSemibold
    ToggleButton.Text = "Running"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 16
    Instance.new("UICorner", ToggleButton)

    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 15, 0, 80)
    StatusLabel.Size = UDim2.new(1, -30, 0, 30)
    StatusLabel.Font = Enum.Font.GothamMedium
    StatusLabel.Text = "Status: Searching..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusLabel.TextSize = 14

    ToggleButton.MouseButton1Click:Connect(function()
        Config.AutoFruit = not Config.AutoFruit
        ToggleButton.Text = Config.AutoFruit and "Running" or "Stopped"
        ToggleButton.BackgroundColor3 = Config.AutoFruit and Color3.fromRGB(65, 165, 65) or Color3.fromRGB(165, 65, 65)
    end)

    function ui.updateStatus(status)
        StatusLabel.Text = "Status: " .. status
    end

    return ui
end

local ui = CreateUI()

-- Start Fruit Finder
local function StartFruitFinder()
    while task.wait() do
        if Config.AutoFruit then
            pcall(function()
                local foundFruit = false

                for _, v in ipairs(workspace:GetChildren()) do
                    if v:IsA("Tool") and v.Name:find("fruit") then
                        foundFruit = true
                        ui.updateStatus("Found Tool Fruit: " .. v.Name)
                        if CollectItem(v) then
                            ui.updateStatus("Collected " .. v.Name)
                        end
                        break
                    end
                end

                if not foundFruit then
                    for _, v in ipairs(workspace:GetChildren()) do
                        if v:IsA("Model") and (v.Name == "Fruit" or v.Name == "fruit") then
                            foundFruit = true
                            ui.updateStatus("Found Model Fruit")
                            if CollectItem(v) then
                                ui.updateStatus("Collected Model Fruit")
                            end
                            break
                        end
                    end
                end

                if not foundFruit and tick() - lastServerHop >= 1 then
                    lastServerHop = tick()
                    ui.updateStatus("Server Hopping...")

                    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
                    for _, server in ipairs(servers.data) do
                        if not serversTried[server.id] then
                            serversTried[server.id] = true
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                            break
                        end
                    end
                end
            end)
        end
    end
end

task.spawn(StartFruitFinder)
