extends Node2D
class_name ClickPointMovement

signal movement_completed(entity: CharacterBody2D, points: PackedVector2Array)

@onready var line2d = $Line2D

@export_range(1, 5) var max_num_movements: int =  3
@export var point_display_scene: PackedScene
@export var moveable_entity: CharacterBody2D

var enabled: bool = false
var current_index_point: int = 0
var is_moving: bool = false

#func _input(event):
#	if event is InputEventMouseButton and event.pressed:
#		if event.button_index == MOUSE_BUTTON_LEFT:
#			add_point(get_global_mouse_position())
#		if event.button_index == MOUSE_BUTTON_RIGHT:
#			enable_movement(true)

func _physics_process(delta):
	if enabled:
		move()

func move():
	var points = movement_points()
	
	if points.is_empty():
		stop_move()
		
	if enabled and moveable_entity.has_node("VelocityComponent2D") and !points.is_empty():
		is_moving = true
		var current_target_point = points[current_index_point]
		var velocity_component = moveable_entity.get_node("VelocityComponent2D")
		
		velocity_component\
			.accelerate_to_position(current_target_point)\
			.move()
			
		if reached_the_target_point(moveable_entity.global_position, current_target_point, velocity_component.max_speed):
			current_index_point += 1

			if current_index_point >= points.size():
				movement_completed.emit(points)
				stop_move()


func stop_move(remove_points: bool = true):
	is_moving = false
	
	if remove_points:
		clear_points()
		
	enable_movement(false)
	
func enable_movement(enable: bool):
	enabled = enable
	
	return self
	
func movement_points() -> PackedVector2Array:
	return line2d.points
	
func add_points(points: PackedVector2Array):
	for point in points:
		add_point(point)
		
func add_point(point: Vector2):
	if movement_point_can_be_added(point):	
		line2d.add_point(point)
		draw_point_scene(point)

func remove_point(point: Vector2):
	if movement_points().is_empty():
		return
	
	var index = line2d.points.find(point)
	
	line2d.remove_point(index)

func clear_points():
	line2d.clear_points()
	current_index_point = 0

func draw_point_scene(position: Vector2):
	if point_display_scene:
		var point_display = point_display_scene.instantiate()
		point_display.global_position = position
		add_child(point_display)
	
	
func reached_the_target_point(from: Vector2, target: Vector2, speed)-> bool:
	return from.distance_to(target) < speed * 0.01
	
func maximum_allowed_movements_reached() -> bool:
	return line2d.get_point_count() == max_num_movements

func movement_point_can_be_added(position: Vector2) -> bool:
	return !is_moving and line2d.get_point_count() < max_num_movements
