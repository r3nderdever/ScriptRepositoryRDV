local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local plr = Players.LocalPlayer

local function JoinTeam()
    -- Ensure the player has a valid team before checking
    if not plr.Team or (plr.Team ~= game.Teams.Marines and plr.Team ~= game.Teams.Pirates) then
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("SetTeam", "Marines")
    end
end

-- Call the function
JoinTeam
()
