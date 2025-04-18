local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local webhook = "https://discord.com/api/webhooks/1360740979644043376/ISGGWffWajSVaJ08jbx3ifcebctRBY1n5k-EwLfiFeKB7w9vBgc1zuW6C0Dt_QktKocM"

local data = LocalPlayer:WaitForChild("Data")
local backpack = LocalPlayer:WaitForChild("Backpack")

local lastState = {
    Level = data:FindFirstChild("Level") and data.Level.Value or nil,
    Fragments = data:FindFirstChild("Fragments") and data.Fragments.Value or nil,
    Race = data:FindFirstChild("Race") and data.Race.Value or nil,
    DevilFruit = data:FindFirstChild("DevilFruit") and data.DevilFruit.Value or nil,
    BackpackItems = {}
}

for _, item in ipairs(backpack:GetChildren()) do
    table.insert(lastState.BackpackItems, item.Name)
end

local function checkForChanges()
    local newLevel = data:FindFirstChild("Level") and data.Level.Value or nil
    local newFragments = data:FindFirstChild("Fragments") and data.Fragments.Value or nil
    local newRace = data:FindFirstChild("Race") and data.Race.Value or nil
    local newFruit = data:FindFirstChild("DevilFruit") and data.DevilFruit.Value or nil

    local currentBackpackItems = {}
    for _, item in ipairs(backpack:GetChildren()) do
        table.insert(currentBackpackItems, item.Name)
    end

    local changes = {}

    if newLevel ~= lastState.Level then
        table.insert(changes, "Level: `" .. tostring(lastState.Level) .. "` ➝ `" .. tostring(newLevel) .. "`")
        lastState.Level = newLevel
    end

    if newFragments ~= lastState.Fragments then
        table.insert(changes, "Fragments: `" .. tostring(lastState.Fragments) .. "` ➝ `" .. tostring(newFragments) .. "`")
        lastState.Fragments = newFragments
    end

    if newRace ~= lastState.Race then
        table.insert(changes, "Race: `" .. tostring(lastState.Race) .. "` ➝ `" .. tostring(newRace) .. "`")
        lastState.Race = newRace
    end

    if newFruit ~= lastState.DevilFruit then
        table.insert(changes, "Devil Fruit: `" .. tostring(lastState.DevilFruit) .. "` ➝ `" .. tostring(newFruit) .. "`")
        lastState.DevilFruit = newFruit
    end

    -- Check for new backpack items
    local previousItems = {}
    for _, item in ipairs(lastState.BackpackItems) do
        previousItems[item] = true
    end

    local newItems = {}
    for _, item in ipairs(currentBackpackItems) do
        if not previousItems[item] then
            table.insert(newItems, item)
        end
    end

    if #newItems > 0 then
        table.insert(changes, "New Backpack Items: `" .. table.concat(newItems, "`, `") .. "`")
        lastState.BackpackItems = currentBackpackItems
    end

    -- If any changes occurred, send webhook
    if #changes > 0 then
        local body = {
            content = "",
            embeds = {{
                title = "Player Stat Update",
                description = table.concat(changes, "\n"),
                color = tonumber(0x00ffcc),
                timestamp = DateTime.now():ToIsoDate()
            }}
        }

        (syn and syn.request or fluxus and fluxus.request or http and http.request or http_request)({
            Url = webhook,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(body)
        })
    end
end

task.spawn(function()
    while true do
        checkForChanges()
        task.wait(1)
    end
end)
