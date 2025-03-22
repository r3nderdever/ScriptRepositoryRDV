repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer
wait(2)

-- message me on discord " R3nderDV. " on discord if ya got any questions, not i am in ireland so my acc should have a timestamp thingymagig.

local Players, ReplicatedStorage, TweenService, HttpService, TeleportService = 
    game:GetService("Players"), 
    game:GetService("ReplicatedStorage"),
    game:GetService("TweenService"),
    game:GetService("HttpService"),
    game:GetService("TeleportService")

local plr = Players.LocalPlayer
local Config = setmetatable({
    AutoFruit = true,
    AutoStoreFruit = true,
    FruitLog = {}
}, {
    __index = _G,
    __newindex = function(t, k, v)
        _G[k] = v
        rawset(t, k, v)
    end
})

local function JoinTeam()
    if plr.Team ~= game.Teams.Marines and plr.Team ~= game.Teams.Pirates then
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("SetTeam", "Marines")
    end
end

JoinTeam()

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

task.wait(1)

local function FindBasePart(model)
    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("BasePart") then return v end
    end
end

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

local function CreateUI()
    local ui = {}
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local MainFrame = Instance.new("Frame", ScreenGui)
    local TopBar = Instance.new("Frame", MainFrame)
    local LogFrame = Instance.new("ScrollingFrame", MainFrame)
    local StatusLabel = Instance.new("TextLabel")
    
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    MainFrame.Position = UDim2.new(0.8, -150, 0.5, -150)
    MainFrame.Size = UDim2.new(0, 300, 0, 300)
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
    
    TopBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    
    local Title = Instance.new("TextLabel", TopBar)
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(1, -30, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "Fruit Finder By R3nderDV."
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 22
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local ToggleButton = Instance.new("TextButton", MainFrame)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(65, 165, 65)
    ToggleButton.Position = UDim2.new(0.5, -75, 0, 70)
    ToggleButton.Size = UDim2.new(0, 150, 0, 35)
    ToggleButton.Font = Enum.Font.GothamSemibold
    ToggleButton.Text = "Working?"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 16
    Instance.new("UICorner", ToggleButton)
    
    local StatusFrame = Instance.new("Frame", MainFrame)
    StatusFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    StatusFrame.Position = UDim2.new(0, 15, 0, 120)
    StatusFrame.Size = UDim2.new(1, -30, 0, 40)
    
    StatusLabel.Parent = StatusFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Size = UDim2.new(1, 0, 1, 0)
    StatusLabel.Font = Enum.Font.GothamMedium
    StatusLabel.Text = "Status: Looking..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusLabel.TextSize = 14
    
    LogFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    LogFrame.Position = UDim2.new(0, 15, 0, 170)
    LogFrame.Size = UDim2.new(1, -30, 0, 120)
    LogFrame.ScrollBarThickness = 6
    LogFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local UserInputService = game:GetService("UserInputService")
    local dragging, dragStart, startPos
    
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    ToggleButton.MouseButton1Click:Connect(function()
        Config.AutoFruit = not Config.AutoFruit
        Config.AutoStoreFruit = Config.AutoFruit
        ToggleButton.Text = Config.AutoFruit and "Working?" or "Stopped"
        ToggleButton.BackgroundColor3 = Config.AutoFruit and Color3.fromRGB(65, 165, 65) or Color3.fromRGB(165, 65, 65)
    end)
    
    function ui.updateLog()
        for _, child in ipairs(LogFrame:GetChildren()) do
            child:Destroy()
        end
        
        local fruitCounts = {}
        for _, entry in ipairs(Config.FruitLog) do
            fruitCounts[entry.fruit] = fruitCounts[entry.fruit] or {count = 0, lastTime = entry.time}
            fruitCounts[entry.fruit].count += 1
            fruitCounts[entry.fruit].lastTime = entry.time
        end
        
        local sortedFruits = {}
        for fruit, data in pairs(fruitCounts) do
            table.insert(sortedFruits, {
                name = fruit,
                count = data.count,
                lastTime = data.lastTime
            })
        end
        
        table.sort(sortedFruits, function(a, b)
            return a.lastTime > b.lastTime
        end)
        
        for i, data in ipairs(sortedFruits) do
            local label = Instance.new("TextLabel", LogFrame)
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 5, 0, 5 + (i-1)*25)
            label.Size = UDim2.new(1, -10, 0, 20)
            label.Font = Enum.Font.GothamMedium
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Text = data.count > 1 and 
                string.format("%s (%d) - %s", data.name, data.count, data.lastTime) or
                string.format("%s - %s", data.name, data.lastTime)
        end
    end
    
    ui.updateStatus = function(status)
        StatusLabel.Text = "Status: " .. status
    end
    
    LoadFruitLog()
    ui.updateLog()
    
    return ui
end

local function HandleAutoStore(tool)
    if Config.AutoStoreFruit and tool:IsA("Tool") and tool.Name:find("Fruit") then
        task.spawn(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", tool:GetAttribute("OriginalName"), tool)
        end)
    end
end

local function StartFruitFinder()
    local ui = CreateUI()
    local lastServerHop = tick()
    local collecting = false
    
    while task.wait() do
        if Config.AutoFruit and not collecting then
            pcall(function()
                local foundFruit = false
                local collected = false
                
                for _, v in ipairs(workspace:GetChildren()) do
                    if v:IsA("Tool") and v.Name:find("fruit") then
                        foundFruit = true
                        collecting = true
                        ui.updateStatus("Found Tool Fruit: " .. v.Name)
                        
                        if CollectItem(v) then
                            collected = true
                            ui.updateLog()
                        end
                        
                        collecting = false
                        break
                    end
                end
                
                if not collected then
                    for _, v in ipairs(workspace:GetChildren()) do
                        if v:IsA("Model") and (v.Name == "Fruit" or v.Name == "fruit") then
                            foundFruit = true
                            collecting = true
                            ui.updateStatus("Found Model Fruit")
                            
                            if CollectItem(v) then
                                collected = true
                                ui.updateLog()
                            end
                            
                            collecting = false
                            break
                        end
                    end
                end
                
                if collected and Config.AutoStoreFruit then
                    ui.updateStatus("Storing Fruits")
                    task.wait(1)
                end
                
                if not foundFruit and tick() - lastServerHop >= 3 then
                    ui.updateStatus("Server Hopping...")
                    task.wait(1)
                    lastServerHop = tick()

                    -- Fetch servers from the API
                    local success, response = pcall(function()
                        return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
                    end)

                    if success then
                        local servers = HttpService:JSONDecode(response)

                        -- Ensure the servers are available
                        if servers and servers.data and #servers.data > 0 then
                            local server = servers.data[math.random(1, #servers.data)]

                            -- Ensure the server object is valid
                            if server and server.id then
                                ui.updateStatus("Teleporting to server...")
                                -- Use TeleportService to teleport to the chosen server
                                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                            else
                                ui.updateStatus("No valid server found!")
                            end
                        else
                            ui.updateStatus("No servers found or API error!")
                        end
                    else
                        ui.updateStatus("Failed to fetch servers!")
                    end
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
                    HandleAutoStore(fr)
                end
                for _, fr in ipairs(plr.Character:GetChildren()) do
                    HandleAutoStore(fr)
                end
            end)
        end
    end
end)

plr.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(HandleAutoStore)
end)

if plr.Character then
    plr.Character.ChildAdded:Connect(HandleAutoStore)
end

print("R3nderDV. on discord, made by rdv.")
StartFruitFinder()
