extends CharacterBody2D

@onready var velocity_component_2d = $VelocityComponent2D
@onready var animation_player = $AnimationPlayer
@onready var animated_sprite_2d = $AnimatedSprite2D

@onready var finite_state_machine = $FiniteStateMachine as FiniteStateMachine

var input_axis: float = 0.0
var input_direction: Vector2 = Vector2.ZERO
var horizontal_direction: Vector2 = Vector2.ZERO

func _physics_process(delta):
	if not is_on_floor():
		velocity_component_2d.apply_gravity().move()
		

func handle_horizontal_movement():
	input_axis = Input.get_axis("ui_left", "ui_right")
	input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	horizontal_direction = translate_x_axis_to_vector(input_axis)

	if horizontal_direction.is_equal_approx(Vector2.ZERO) and is_on_floor():
		velocity_component_2d.decelerate()
	else:
		velocity_component_2d.accelerate_in_direction(horizontal_direction)

	animated_sprite_2d.flip_h = velocity_component_2d.last_faced_direction.is_equal_approx(Vector2.LEFT)

func translate_x_axis_to_vector(input_axis: float) -> Vector2:
	var horizontal_direction: Vector2 = Vector2.ZERO
	
	match input_axis:
		-1.0:
			horizontal_direction = Vector2.LEFT 
		1.0:
			horizontal_direction = Vector2.RIGHT
			
	return horizontal_direction
	
