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

-- Server Hop System (Replacing Old Server Hop Logic)
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
        Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
    else
        Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
    end

    if Site.nextPageCursor then
        foundAnything = Site.nextPageCursor
    end

    for _, v in pairs(Site.data) do
        local Possible = true
        local ID = tostring(v.id)

        if tonumber(v.maxPlayers) > tonumber(v.playing) then
            for _, Existing in pairs(AllIDs) do
                if ID == tostring(Existing) then
                    Possible = false
                    break
                end
            end

            if Possible then
                table.insert(AllIDs, ID)
                writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
                TeleportService:TeleportToPlaceInstance(PlaceID, ID, plr)
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
                
                -- If no fruit was found, hop servers
                if not foundFruit and tick() - lastServerHop >= 3 then
                    task.wait(1)
                    lastServerHop = tick()
                    Teleport() -- Calls the new Teleport function
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
                    if fr:IsA("Tool") and fr.Name:find("Fruit") then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", fr:GetAttribute("OriginalName"), fr)
                    end
                end
                for _, fr in ipairs(plr.Character:GetChildren()) do
                    if fr:IsA("Tool") and fr.Name:find("Fruit") then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", fr:GetAttribute("OriginalName"), fr)
                    end
                end
            end)
        end
    end
end)

plr.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and child.Name:find("Fruit") then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", child:GetAttribute("OriginalName"), child)
        end
    end)
end)

if plr.Character then
    plr.Character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and child.Name:find("Fruit") then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", child:GetAttribute("OriginalName"), child)
        end
    end)
end

StartFruitFinder()
