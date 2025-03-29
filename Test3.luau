repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

local Players, ReplicatedStorage, HttpService, TeleportService = 
    game:GetService("Players"), 
    game:GetService("ReplicatedStorage"),
    game:GetService("HttpService"),
    game:GetService("TeleportService")

local plr = Players.LocalPlayer
local Config = {
    AutoFruit = true,
    FruitLog = {}
}

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

local function FindBasePart(model)
    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("BasePart") then return v end
    end
end

local function CollectItem(item)
    if not item then return false end

    -- Check if the fruit is already in the player's inventory
    for _, heldItem in ipairs(plr.Backpack:GetChildren()) do
        if heldItem:IsA("Tool") and heldItem.Name == item.Name then
            return false -- Skip if already in inventory
        end
    end

    for _, charItem in ipairs(plr.Character:GetChildren()) do
        if charItem:IsA("Tool") and charItem.Name == item.Name then
            return false -- Skip if already holding
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
            until tick() - startTime > 10
        end
    end
    return false
end

local function StartFruitFinder()
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
                        
                        if CollectItem(v) then
                            collected = true
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
                            
                            if CollectItem(v) then
                                collected = true
                            end
                            
                            collecting = false
                            break
                        end
                    end
                end
                
                if not foundFruit and tick() - lastServerHop >= 1 then
                    task.wait(1) -- Server hop timer set to 1 second
                    lastServerHop = tick()
                    
                    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
                    local server = servers.data[math.random(1, #servers.data)]
                    if server then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                    end
                end
            end)
        end
    end
end

print("Fruit Finder Script Started")
StartFruitFinder()
