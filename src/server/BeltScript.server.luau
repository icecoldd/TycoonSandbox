local CollectionService = game:GetService("CollectionService")

local TAG = "Conveyor" -- make sure the tag name matches exactly in Studio

-- Get all currently tagged parts
for _, part in ipairs(CollectionService:GetTagged(TAG)) do
	if part:IsA("BasePart") then
		part.AssemblyLinearVelocity = Vector3.new(10, 0, 0) -- Set the desired velocity
	end
end

-- Whenever a new part is tagged later, set its velocity too
CollectionService:GetInstanceAddedSignal(TAG):Connect(function(part)
	if part:IsA("BasePart") then
		part.AssemblyLinearVelocity = Vector3.new(10, 0, 0) -- Set the desired velocity
	end
end)