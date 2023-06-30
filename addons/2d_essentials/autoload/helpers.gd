@tool
extends Node
class_name Utilities

## Generate n random directions on the angle range provided
## from an origin vector that will be rotated accordingly
# [Important] The angles needs to be on degrees
#
## [codeblock]
##	Globals2D.generate_random_directions_on_angle_range(Vector2.ZERO, -45, 45, 5)
## [/codeblock]
##
func generate_random_directions_on_angle_range(origin: Vector2 = Vector2.UP, min_angle_range: float = 0.0, max_angle_range: float = 360.0, num_directions: int = 10) -> Array[Vector2]:
	var random_directions: Array[Vector2] = []
	random_directions.resize(num_directions) # Improve performance if we know the final size
	
	var min_angle_range_in_rad = deg_to_rad(min_angle_range)
	var max_angle_range_in_rad = deg_to_rad(max_angle_range)
	
	for i in range(num_directions):
		var random_angle = generate_random_angle(min_angle_range_in_rad, max_angle_range_in_rad)
		random_directions.append(origin.rotated(random_angle))
		
	return random_directions


func generate_random_angle(min_angle_range: float = 0.0, max_angle_range: float = 360.0) -> float:
	return lerp(min_angle_range, max_angle_range, randf())
