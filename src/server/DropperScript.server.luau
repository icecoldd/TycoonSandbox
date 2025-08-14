local CollectionService = game:GetService("CollectionService")
local DropperTemplate = game.ServerStorage:WaitForChild("DropperTemplate")
local TAG = "Dropper"

-- Debounce tables keyed by dropper MODEL
local active = {}     -- model -> true if a loop is running
local watched = {}    -- model -> true if we've attached the Unlocked listener

local function getModelFromTagged(inst)
	if inst:IsA("Model") then return inst end
	if inst:IsA("BasePart") then return inst.Parent end
	return nil
end

local function startDroppingFrom(part)
	local model = part.Parent
	if not model then return end
	if active[model] then return end  -- ✅ prevents double loops per model
	active[model] = true

	task.spawn(function()
		while task.wait(2) do
			if not model or model:GetAttribute("Unlocked") ~= true then
				active[model] = nil
				break
			end

			local drop = DropperTemplate:Clone()
			drop.Parent = model:FindFirstChild("DropperParts") or model
			drop:SetAttribute("CashToGive", model:GetAttribute("CashPerDrop"))

			local cf = part.CFrame * CFrame.new(0, 2, 0)
			if drop:IsA("BasePart") then
				drop.CFrame = cf
				drop.Anchored = false
			else
				drop:PivotTo(cf)
				for _, d in ipairs(drop:GetDescendants()) do
					if d:IsA("BasePart") then d.Anchored = false end
				end
			end
		end
	end)
end

local function watchModelForUnlock(part)
	local model = part.Parent
	if not model or watched[model] then return end
	watched[model] = true  -- ✅ only one listener per model

	-- Start now if already unlocked
	if model:GetAttribute("Unlocked") == true then
		startDroppingFrom(part)
	end

	-- Start later when Unlocked flips true
	model:GetAttributeChangedSignal("Unlocked"):Connect(function()
		if model:GetAttribute("Unlocked") == true then
			startDroppingFrom(part)
		end
	end)
end

-- Handle existing tagged instances at startup
for _, inst in ipairs(CollectionService:GetTagged(TAG)) do
	if inst:IsA("BasePart") and inst.Parent then
		watchModelForUnlock(inst)
	end
end

-- Handle future tagged instances
CollectionService:GetInstanceAddedSignal(TAG):Connect(function(inst)
	if inst:IsA("BasePart") and inst.Parent then
		watchModelForUnlock(inst)
	end
end)
