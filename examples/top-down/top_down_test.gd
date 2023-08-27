extends CharacterBody2D

@onready var godot_essentials_top_down_movement_component: GodotEssentialsTopDownMovementComponent = $GodotEssentialsTopDownMovementComponent


func _physics_process(delta):
	var input_direction: Vector2 = get_input_direction()
	
	if input_direction.is_zero_approx():
		godot_essentials_top_down_movement_component.decelerate()
	else:
		godot_essentials_top_down_movement_component\
			.accelerate(input_direction)
			
	godot_essentials_top_down_movement_component.move()

		
	
func get_input_direction() -> Vector2:
	return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
