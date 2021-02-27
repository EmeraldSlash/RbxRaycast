# RbxRaycast
A simple, extensible raycasting wrapper for Roblox

When required this module returns a raycast function.
	
Example:
```lua
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
```		

? before something means it is optional / can be nil.

## Arguments
The raycast function takes the following as arguments.
- **Vector3** startPosition
- **Vector3** direction
- **RaycastParams** params
- **?function** customFilter: *Defaults to returning true when (CanCollide AND (Transparency < 1)*
- **?bool** deepCopyParams: *Defaults to false*
- **?number** stopRaycastingThreshold: *Defaults to 0*

## Return Values
The raycast function will always stop before doing anything else if there is no hit,
i.e. if workspace:Raycast() returns nil, then function will stop and return nil instantly.
The raycast function returns a tuple:
- **?Part/TerrainCell** instance
- **?Vector3** position
- **?Vector3** normal
- **?Enum** material

Here's what gets returned in different situations:
- Collision with a part: part, position, normal, material
- Collision with terrain: terrain, position, normal, material
- StopRaycastingThreshold reached: nil, position, nil, nil
- Otherwise: nil, nil, nil, nil

## Custom Filter
The custom filter function is defined as follows. It returns true when should collide,
otherwise the return value should evaluate to false. It takes the arguments:
- **Part** part
- **Vector3** position
- **Vector3** normal
- **Enum** material
