-- Combined additions
-- 1. Server hop logic after 2 seconds of no fruits
-- 2. Auto team join (Marines)

-- === SERVER HOP ===
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local PlaceId = game.PlaceId
local player = game:GetService("Players").LocalPlayer
local lastFruitFound = tick()

-- Update timestamp when fruit is detected
local function updateFruitDetection()
    lastFruitFound = tick()
end

-- Check for fruits every second
spawn(function()
    while true do
        local foundFruit = false
        for _, fruit in ipairs(game.Workspace:GetChildren()) do
            if fruit:IsA("Tool") and fruit:FindFirstChild("Handle") and fruit.Name:lower():find("fruit") then
                foundFruit = true
                updateFruitDetection()
                break
            end
        end

        if not foundFruit and (tick() - lastFruitFound) >= 2 then
            game.StarterGui:SetCore("SendNotification", {
                Title = "Server Hop",
                Text = "No fruits found. Hopping...",
                Duration = 2
            })
            TeleportService:Teleport(PlaceId, player)
        end

        wait(1)
    end
end)

-- === AUTO TEAM JOIN ===
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local plr = game.Players.LocalPlayer

local function JoinTeam()
    if not plr.Team or (plr.Team ~= game.Teams.Marines and plr.Team ~= game.Teams.Pirates) then
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("SetTeam", "Marines")
    end
end

JoinTeam()

-- === MAIN SCRIPT CONTINUES BELOW ===

-- [PASTE YOUR ENTIRE ORIGINAL MAIN SCRIPT HERE STARTING FROM "-- Services"]

-- Services
local Players = game:GetService("Players")
