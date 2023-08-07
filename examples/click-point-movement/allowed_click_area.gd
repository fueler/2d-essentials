extends Area2D

@onready var click_point_movement = $"../ClickPointMovement"

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			click_point_movement.add_point(get_global_mouse_position())
		if event.button_index == MOUSE_BUTTON_RIGHT:
			click_point_movement.enable_movement(true)
