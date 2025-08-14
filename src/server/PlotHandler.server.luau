local Plots = game.Workspace.Plots

local TemplatePlot = game.Workspace.TemplatePlot

game.Players.PlayerAdded:Connect(function(player)
    -- Get a plot for the player
    
    -- Cycle through all existing plots in Plots folder
    -- if a plot is taken, skip it
    -- Otherwise, take the plot and assign it to the player
    for _, plot in Plots:GetChildren() do
        if plot:GetAttribute("Taken") then continue end

        -- plot is not taken, so we want to take it
        plot:SetAttribute("Taken", true)
        plot:SetAttribute("Owner", player.UserId)

        print("Plot assigned to player: " .. player.Name)

        -- Create a folder for items in the plot and name it 'Items'
        -- This folder will be parented to the current plot we are examining
        local ItemsFolder = Instance.new('Folder')
        ItemsFolder.Name = "Items"
        ItemsFolder.Parent = plot

        -- Load Buttons
        local TemplateButtons = TemplatePlot.Buttons:Clone()
        local TemplateItems = TemplatePlot.Items

        for _, Button in TemplateButtons:GetChildren() do
            -- Get the pos of the button relative to the template plot
            -- In other words, how far away is the button from the center of the template plot (20,30)
            local RelativeCFrame = TemplatePlot.CFrame:toObjectSpace(Button.CFrame)
            -- Set the button's CFrame in the same relative position as it is in the template plot, but using the current plot's CFrame
            Button.CFrame = plot.CFrame:ToWorldSpace(RelativeCFrame)

            Button.Touched:Connect(function(hit)
                local player = game.Players:GetPlayerFromCharacter(hit.Parent)
                if not player then return end
        
                if plot:GetAttribute("Owner") ~= player.UserId then return end

                if Button:GetAttribute("Debounce") then return end 

                Button:SetAttribute("Debounce", true) -- prevent multiple clicks
                
                task.delay(2, function()
                    if Button then
                        Button:SetAttribute("Debounce", false) -- reset debounce after 2 seconds
                    end
                end)

                -- TODO: remove currency / check enough currency
                local itemToUnlock = Button:GetAttribute("idOfItemToUnlock")
                if not itemToUnlock then
                    warn('You forgot to add an idOfItemToUnlock attribute')
                    return
                end

                local Price = Button:GetAttribute("price")

                if Price then
                    if player.leaderstats.Cash.Value < Price then
                        warn('You cannot afford this item!')
                        return
                    end
                    player.leaderstats.Cash.Value -= Price
                    print('Item purchased for: ' .. player.Name .. ' - ' .. Price)
                end

                for _, item in TemplateItems:GetChildren() do
                    if item:GetAttribute("id") ~= itemToUnlock then continue end
                    -- found correct item
                    -- clone it our and re-position for our plot
                    local itemClone = item:Clone()
                    local itemCFrame 

                    if itemClone:IsA('Model') then
                        itemCFrame = itemClone:GetPivot() -- model
                    elseif itemClone:IsA('BasePart') then
                        itemCFrame = itemClone.CFrame
                    else
                        warn('Item is not a model or part: ' .. item.Name)
                        return
                    end

                    local relativeItemCFrame = TemplatePlot.CFrame:toObjectSpace(itemCFrame)
                    local worldCFrameOfNewPlot = plot.CFrame:ToWorldSpace(relativeItemCFrame)

                    if itemClone:IsA('Model') then
                        itemClone:PivotTo(worldCFrameOfNewPlot)
                    elseif itemClone:IsA('BasePart') then
                        itemClone.CFrame = worldCFrameOfNewPlot
                    end

                    itemClone.Parent = ItemsFolder
                    Button:Destroy() -- remove the button after unlocking the item
                    itemClone:SetAttribute("Unlocked", true) -- mark the item as unlocked
                end
            end)

            Button.Parent = TemplateButtons
        end
        TemplateButtons.Parent = plot

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
