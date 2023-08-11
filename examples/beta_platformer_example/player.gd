extends CharacterBody2D

@onready var velocity_component_2d = $VelocityComponent2D
@onready var animation_player = $AnimationPlayer
@onready var animated_sprite_2d = $AnimatedSprite2D

@onready var finite_state_machine = $FiniteStateMachine as FiniteStateMachine
@onready var jump_state = $FiniteStateMachine/JumpState
@onready var wall_slide_state = $FiniteStateMachine/WallSlideState

var input_axis: float = 0.0
var input_direction: Vector2 = Vector2.ZERO
var horizontal_direction: Vector2 = Vector2.ZERO
var is_left_direction: bool = false

func _physics_process(delta):
	if not is_on_floor():
		velocity_component_2d.apply_gravity().move()
	
	handle_horizontal_movement()
		

func handle_horizontal_movement():
	input_axis = Input.get_axis("ui_left", "ui_right")
	input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	horizontal_direction = translate_x_axis_to_vector(input_axis)
	is_left_direction = velocity_component_2d.last_faced_direction.is_equal_approx(Vector2.LEFT)
	
	if not velocity_component_2d.is_wall_sliding and not velocity_component_2d.is_wall_climbing:
		if horizontal_direction.is_zero_approx() and is_on_floor() and not finite_state_machine.current_state_is(jump_state):
			velocity_component_2d.decelerate()
		else:
			velocity_component_2d.accelerate_in_direction(horizontal_direction)
		
	# Avoid assigning the variable when it's the same to avoid blinked animations
	if is_left_direction != animated_sprite_2d.flip_h:
		animated_sprite_2d.flip_h = is_left_direction

func translate_x_axis_to_vector(input_axis: float) -> Vector2:
	var horizontal_direction: Vector2 = Vector2.ZERO
	
	match input_axis:
		-1.0:
			horizontal_direction = Vector2.LEFT 
		1.0:
			horizontal_direction = Vector2.RIGHT
			
	return horizontal_direction
	