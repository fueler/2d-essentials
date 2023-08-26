class_name ProjectileComponent extends Node2D

signal follow_started(target:Node2D)
signal follow_stopped(target: Node2D)
signal target_swapped(current_target: Node2D, previous_target:Node2D)
signal bounced(position: Vector2)


@export_group("Speed")
@export var max_speed: float = 10.0
@export var acceleration: float = 0.0

@export_group("Bounce")
@export var bounce_enabled: bool = false
@export var max_bounces: int = 10

@onready var projectile = get_parent() as Node2D

var direction: Vector2 = Vector2.ZERO

var target: Node2D
var follow_target: bool = false:
	set(value):
		if value != follow_target:
			if follow_target:
				follow_started.emit(target)
			else:
				follow_stopped.emit(target)
				
		follow_target = value

var bounced_positions: Array[Vector2] = []

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	var parent_node = get_parent()
	
	if parent_node == null or not parent_node is Node2D:
		warnings.append("This component needs a Node2D parent in order to work properly")
			
	return warnings


func swap_target(next_target: Node2D):
	target_swapped.emit(target, next_target)
	target = next_target
	
	
func stop_follow_target():
	follow_target = false


func begin_follow_target():
	follow_target = true

	
func target_position() -> Vector2:
	if target:
		return projectile.position.direction_to(target.global_position)
	
	return Vector2.ZERO

	
func bounce(new_direction: Vector2) -> Vector2:
	if bounced_positions.size() < max_bounces:
		bounced_positions.append(projectile.global_position)
		direction = direction.bounce(new_direction)
		bounced.emit(bounced_positions.back())
	
	return direction


