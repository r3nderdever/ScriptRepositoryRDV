local fruitsList = {
    "Fruit ", "Rocket Fruit", "Spin Fruit", "Ghost Fruit", "Spring Fruit", "Bomb Fruit", "Spike Fruit", "Smoke Fruit", "Blade Fruit",
    "Sand Fruit", "Ice Fruit", "Dark Fruit", "Diamond Fruit", "Light Fruit", "Rubber Fruit", "Barrier Fruit", "Magma Fruit", "Phoenix Fruit",
    "Love Fruit", "Spider Fruit", "Sound Fruit", "Buddha Fruit", "Quake Fruit", "Gravity Fruit", "Control Fruit", "T-Rex Fruit",
    "Mammoth Fruit", "Spirit Fruit", "Venom Fruit", "Shadow Fruit", "Rumble Fruit", "Portal Fruit", "Blizzard Fruit", "Dragon Fruit",
    "Leopard Fruit", "Dough Fruit", "Dragon (West) Fruit", "Dragon (East) Fruit", "Kitsune Fruit", "Gas Fruit", "Flame Fruit", "Yeti Fruit"
}

-- Find fruits and count them
local function countFruits()
    local count = 0
    for _, fruit in ipairs(workspace:GetChildren()) do
        if table.find(fruitsList, fruit.Name) and fruit:FindFirstChild("Handle") then
            count += 1
        end
    end
    return count
end

-- Teleport-related code
local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour

local function TPReturner()
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
            if Possible == true then
                table.insert(AllIDs, ID)
                wait()
                pcall(function()
                    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                    wait()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
                end)
                wait(4)
                return true -- Successful attempt
            end
        end
    end
    return false -- No teleport attempt succeeded
end

local isTeleporting = false

function Teleport()
    if isTeleporting then return end
    isTeleporting = true

    task.spawn(function()
        while isTeleporting do
            local success = pcall(function()
                TPReturner()
                if foundAnything ~= "" then
                    TPReturner()
                end
            end)
            wait(1) -- Retry every 1 second
        end
    end)
end

-- Main logic: Wait for player spawn and check fruit conditions
task.spawn(function()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    -- Delay 1.5 seconds after spawn
    task.delay(1.5, function()
        local fruitCount = countFruits()
        if fruitCount > 0 then
            -- If fruits are found, call tweenToNearestFruit() after 2 seconds
            task.delay(2, function()
                tweenToNearestFruit()  -- Call your tween function here
            end)
        end
    end)

    -- Fruit detection loop
    local noFruitTime = 0
    while task.wait(0.05) do
        local fruitCount = countFruits()
        if fruitCount == 0 then
            noFruitTime += 0.05
            if noFruitTime >= 3 then
                Teleport()
                break -- Stops fruit search after starting teleport loop
            end
        else
            noFruitTime = 0
        end
    end
end)
