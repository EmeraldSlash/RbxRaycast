--[[
	
	Raycast.
	Author: EmeraldSlash
	Date: 2020-07-26.
	
	When required this module returns a raycast function.
	
	Example:
	
		local raycast = require(script.Raycast)
		
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = {workspace.Folder}
		
		local origin = Vector3.new(0, 0, 0)
		local direction = Vector3.new(10, 10, 10)
		
		-- this in fact the default filter, but is being used here as a custom filter to demonstrate
		local filter = function(hit, position, normal, material)
			return hit.CanCollide and hit.Transparency < 1
		end
		
		local hit, position, normal, material = raycast(origin, direction, params, filter, true, 0.5)
		
		-- this case must be handled manually
		if not position then
			position = origin + direction
		end
		
	? before something means it is optional / can be nil.
	
	The raycast function takes as arguments:
		Vector3			startPosition
		Vector3			direction
		RaycastParams	params
		?function		customFilter
								Defaults to true when (CanCollide AND (Transparency < 1)
		?bool 			deepCopyParams
								Defaults to false
		?number 			stopRaycastingThreshold
								Defaults to 0
	
	The raycast function will always stop before doing anything else if there is no hit,
	i.e. if workspace:Raycast() returns nil, then function will stop and return nil instantly.
	
	The custom filter function is defined as follows. It returns true when should collide,
	otherwise the return value should evaluate to false. It takes the arguments:
		Part		part
		Vector3	position
		Vector3	normal
		Enum		material
	
	The raycast function returns a tuple:
		?Part/TerrainCell	instance
		?Vector3				position
		?Vector3				normal
		?Enum					material
	
	Here's what gets returned in different situations:
		Collision with a part:				part, position, normal, material
		Collision with terrain:				terrain, position, normal, material
		StopRaycastingThreshold reached: nil, position, nil, nil
		Otherwise:								nil, nil, nil, nil
	
--]]

local defaultStop = 0

local function defaultEvaluator(instance)
	return instance.CanCollide and instance.Transparency < 1
end

local function deepCopy(t)
	if type(t) == "table" then
		local nt = {}
		for k, v in pairs(t) do
			nt[deepCopy(k)] = deepCopy[v]
		end
		return nt
	else
		return t
	end
end

local function raycast(start, direction, params, copy, stop, evaluator)
	local origin = start
	local maxLength = direction.Magnitude
	local length = maxLength
	
	if not stop then stop = defaultStop end
	if not evaluator then evaluator = defaultEvaluator end
	
	local filter = params.FilterDescendantsInstances
	if copy then
		filter = deepCopy(filter)
		local nParams = RaycastParams.new()
		nParams.FilterType = params.FilterType
		nParams.IgnoreWater = params.IgnoreWater
		params = nParams
	end
	
	local isBlacklist = params.FilterType == Enum.RaycastFilterType.Blacklist
	
	while true do
		params.FilterDescendantsInstances = filter
		
		local result = workspace:Raycast(origin, direction.Unit * length, params)
		if not result then break end
		
		local ins, nor, mat
		ins, origin, nor, mat = result.Instance, result.Position, result.Normal, result.Material
		if (not ins:IsA("BasePart")) or evaluator(ins, origin, nor, mat) then
			return ins, origin, nor, mat
		end
		
		length -= (start - origin).Magnitude
		if (length <= stop) then
			return nil, origin
		end

		if isBlacklist then
			table.insert(filter, ins)
		end
	end
	
	return nil
end

return raycast
