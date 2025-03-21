repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

-- this script will put a file in your executor to log any fruits, some parts of this script are scrapped from a ton of other scripts made by me and some other people, mostly by me. you can edit it to your liking but i advise you not to, for safety of your account. made by R3nderDV. on Discord. if you want you can give me like 10 rbx or smth and ill work on a script for you, more rbx = more work on it, avg 20 for a basic menu with actual working stuff or whatever.

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
    
    local part = Instance.new("Part")
    part.Size = Vector3.new(2, 2, 2)
    part.Transparency = 1
    part.CanCollide = false
    part.Anchored = true
    part.Position = item:IsA("Tool") and item:FindFirstChild("Handle") and item.Handle.Position or FindBasePart(item).Position
    part.Parent = workspace
    
    local tween = TweenService:Create(plr.Character.HumanoidRootPart, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))})
    tween:Play()
    tween.Completed:Wait()
    
    if not item:IsDescendantOf(workspace) then
        LogFruit(item.Name)
        part:Destroy()
        return true
    end
    
    part:Destroy()
    return false
end

local function HandleAutoStore(tool)
    if Config.AutoStoreFruit and tool:IsA("Tool") and tool.Name:find("Fruit") then
        task.spawn(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", tool:GetAttribute("OriginalName"), tool)
        end)
    end
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
                
                if collected and Config.AutoStoreFruit then
                    task.wait(1)
                end
                
                if not foundFruit and tick() - lastServerHop >= 3 then
                    task.wait(1)
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

print("Fruit Finder By R3nderDV on Discord")
StartFruitFinder()
