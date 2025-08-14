local CollectionService = game:GetService("CollectionService")
local COLLECTOR_TAG = "Collector"

-- helper to hook a single collector (call for existing + future)
local function wireCollector(collectorPart)
	if not collectorPart:IsA("BasePart") then return end
	collectorPart.Touched:Connect(function(hit)
		-- your existing on-touch logic goes here
		-- e.g., check CashToGive, find plot owner, credit, Destroy hit, etc.
        if hit:GetAttribute("CashToGive") then
                local plot = collectorPart.Parent.Parent.Parent
                if not plot then warn('No Plot') 
                    return 
                end

                local PlotOwnerUserId = plot:GetAttribute("Owner")

                if not PlotOwnerUserId then warn('No Plot Owner') 
                    return 
                end

                hit:Destroy() -- Destroy the part that touched the collector

                -- found the plot owner
                local PlayerObject  = game.Players:GetPlayerByUserId(PlotOwnerUserId)
                PlayerObject.leaderstats.Cash.Value += hit:GetAttribute("CashToGive")
        end
	end)
end

-- 1) wire collectors that already exist at server start
for _, inst in ipairs(CollectionService:GetTagged(COLLECTOR_TAG)) do
	wireCollector(inst)
end

-- 2) ✅ wire collectors that appear later (new plots)
CollectionService:GetInstanceAddedSignal(COLLECTOR_TAG):Connect(function(inst)
	wireCollector(inst)
end)
