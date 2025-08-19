local ServerStorage = game:GetService("ServerStorage")
local DropperTemplate = ServerStorage:WaitForChild("DropperTemplate")
local PlotsFolder = workspace:WaitForChild("Plots")

-- Start a spawner loop for ONE dropper, only once
local function setupDropper(dropper: Instance)
	if dropper:GetAttribute("SpawnerStarted") then return end
	dropper:SetAttribute("SpawnerStarted", true)

	-- Wait (with timeout) for required children on this dropper
	local drop = dropper:WaitForChild("Drop", 10)
	local dropperParts = dropper:WaitForChild("DropperParts", 10)
	if not drop or not dropperParts then
		warn(("Dropper %s missing Drop or DropperParts"):format(dropper.Name))
		return
	end

	-- Run the spawn loop in its own thread so we don't block setup of other droppers
	task.spawn(function()
		while dropper.Parent do
			local newDrop = DropperTemplate:Clone()
			newDrop.CFrame = drop.CFrame - Vector3.new(0, 2, 0)
			newDrop:SetAttribute("CashToGive", dropper:GetAttribute("CashPerDrop") or 0)
			newDrop.Parent = dropperParts

			task.wait(2) -- spawn rate
		end
	end)
end

-- Prepare a plot when it becomes available
local function setupPlot(plot: Instance)
	-- Items might arrive later; wait briefly
	local items = plot:WaitForChild("Items", 10)
	if not items then
		warn("No Items folder found in plot: " .. plot.Name)
		return
	end

	-- Handle existing droppers in this plot
	for _, child in items:GetChildren() do
		if child.Name == "Dropper" then
			setupDropper(child)
		end
	end

	-- Handle droppers added later to this plot
	items.ChildAdded:Connect(function(child)
		if child.Name == "Dropper" then
			setupDropper(child)
		end
	end)
end

-- Handle plots already present (if any)
for _, plot in PlotsFolder:GetChildren() do
	setupPlot(plot)
end

-- Handle plots that appear later (e.g., after assignment)
PlotsFolder.ChildAdded:Connect(function(plot)
	setupPlot(plot)
end)