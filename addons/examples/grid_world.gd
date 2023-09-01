extends Node2D


@onready var character_body_2d: CharacterBody2D = $CharacterBody2D
@onready var godot_essentials_grid_movement_component: GodotEssentialsGridMovementComponent = $CharacterBody2D/GodotEssentialsGridMovementComponent


func _input(event):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	
	if direction == Vector2.RIGHT:
		godot_essentials_grid_movement_component.follow_path([Vector2.RIGHT,Vector2.RIGHT, Vector2.DOWN])
		
	if direction == Vector2.DOWN:
		godot_essentials_grid_movement_component.teleport_to(Vector2(100,  50))
		
	godot_essentials_grid_movement_component.move(direction)
