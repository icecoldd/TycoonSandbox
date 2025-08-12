local Plots = game.Workspace.Plots

game.Players.PlayerAdded:Connect(function(player)
    -- Get a plot for the player
    
    for _, plot in Plots:GetChildren() do
        if plot:GetAttribute("Taken") then continue end
        -- plot is not taken, so we want to take it
        plot:SetAttribute("Taken", true)
        plot:SetAttribute("Owner", player.UserId)

        print("Plot assigned to player: " .. player.Name)
        break
    end
end)

game.Players.PlayerRemoving:Connect(function(player)
    -- Release the plot when the player leaves
    for _, plot in Plots:GetChildren() do
        if not plot:GetAttribute("Owner") then continue end
        -- the plot is owned by the player
        if plot:GetAttribute("Owner") == player.UserId then
            plot:SetAttribute("Taken", false)
            plot:SetAttribute("Owner", nil)
        end
        break
    end

    print("Plot released from player: " .. player.Name)
end)
