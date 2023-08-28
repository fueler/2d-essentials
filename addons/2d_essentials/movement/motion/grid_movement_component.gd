class_name GodotEssentialsGridMovementComponent extends Node2D

signal moved(from: Vector2, to: Vector2, direction: Vector2)
signal flushed_recorded_grid_movements(movements: Array[Vector2])
signal movements_completed(movements: Array[Vector2])

@export_group("GridSize")
## Width of each grid cell along the x-axis
@export var grid_width: int = 16
## Height of each grid cell along the y-axis
@export var grid_height: int = 16


@export_group("GridBehaviour")
## Number of grid movements recorded before deletion (set to 0 to keep them indefinitely)
@export var max_recorded_grid_movements: int = 5
## Number of movements to be performed before emitting a signal notification.
@export var emit_signal_every_n_movements: int = 3

var body: CharacterBody2D = get_parent() as CharacterBody2D

var recorded_grid_movements: Array[Dictionary] = []


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	var parent_node = get_parent()
	
	if parent_node == null or not parent_node is CharacterBody2D:
		warnings.append("This component needs a CharacterBody2D parent in order to work properly")
			
	return warnings


func _ready():
	moved.connect(on_moved)
	flushed_recorded_grid_movements.connect(on_flushed_recorded_grid_movements)
	
	
func follow_path(moves: Array[Vector2]):
	pass


func move(direction: Vector2):
	direction = _normalize_vector(direction)
	
	var original_position = body.global_position
	var next_position = direction * Vector2(grid_width, grid_height)
	
	if next_position == body.global_position:
		return
	
	body.global_position += next_position
	look_at(direction + body.global_position)

	moved.emit({
		"from": original_position, 
		"to": next_position, 
		"direction": direction
	})
	

func on_moved(from: Vector2, to: Vector2, direction: Vector2):
	if max_recorded_grid_movements == 0 or recorded_grid_movements.size() < max_recorded_grid_movements:
		recorded_grid_movements.append({"from":from, "to": to, "direction": direction})
		
	if recorded_grid_movements.size() >= max_recorded_grid_movements:
		flushed_recorded_grid_movements.emit(recorded_grid_movements)


func on_flushed_recorded_grid_movements(movements: Array[Vector2]):
	movements.clear()


func _normalize_vector(value: Vector2) -> Vector2:
	return value if value.is_normalized() else value.normalized()
