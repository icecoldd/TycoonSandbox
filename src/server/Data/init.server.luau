local ProfileService = require(script:WaitForChild('ProfileService'))

local ProfileTemplate = {
    Cash = 0, -- Default cash amount
    Items = {}, -- Table to hold items owned by the player

}

local ProfileStore = ProfileService.GetProfileStore(

    "PlayerData", -- Name of the profile store
    ProfileTemplate
)

local Profiles = {} -- Table to hold all loaded profiles

local function playerAdded(player)
    local profile = ProfileStore:LoadProfileAsync("Player_"..player.UserId)

    if profile then
        profile:AddUserId(player.UserId) -- Link profile to player
        profile:Reconcile() -- Ensure profile is in sync with template

        profile:ListenToRelease(function()
            Profiles[player] = nil
            -- Handle profile release (e.g., when player leaves)
            player:Kick("Your profile has been released.")
        end)

        if player:IsDescendantOf(game.Players) == true then
            Profiles[player] = profile -- Store the profile in the Profiles table
        else
            profile.Release() -- Release the profile if player is not in game
        end
    else
        player:Kick("Failed to load your profile. Please try again later.")
    end
end

-- When a player joins the game
game.Players.PlayerAdded:Connect(function(player) 
    playerAdded(player)

    local profile = Profiles[player]
    if not profile then
        warn('No profile')
        return
    end    

    local folder = Instance.new('Folder')
    folder.Name = "leaderstats"
    folder.Parent = player

    local cash = Instance.new('IntValue')
    cash.Name = "Cash"
    cash.Value = profile.Data.Cash or 0 -- Initialize with the cash value from the profile
    cash.Parent = folder

    cash:GetPropertyChangedSignal('Value'):Connect(function()
        profile.Data.Cash = cash.Value -- Update the profile data when cash changes
    end)
end)

game.Players.PlayerRemoving:Connect(function(player)
    local profile = Profiles[player]
    if profile then
        profile:Release() -- Release the profile when player leaves
    end
end)

for _, player in game.Players:GetPlayers() do
    task.spawn(playerAdded, player)
end