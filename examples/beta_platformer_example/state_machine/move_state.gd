class_name MoveState extends State

@export var idle_state: State
@export var walk_state: State
@export var run_state: State
@export var jump_state: State
@export var dash_state: State
@export var falling_state: State
@export var land_state: State

@export var actor: VelocityComponent2D

@onready var finite_state_machine = get_tree().get_first_node_in_group("finite_state_machine") as FiniteStateMachine

@export var animated_sprite: AnimatedSprite2D
@export var animation_player: AnimationPlayer

var input_axis: float = 0.0
var input_direction: Vector2 = Vector2.ZERO
var horizontal_direction: Vector2 = Vector2.ZERO
var is_left_direction: bool = false


func _input(event: InputEvent):
	input_axis = Input.get_axis("ui_left", "ui_right")
	input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	horizontal_direction = translate_x_axis_to_vector(input_axis)
	is_left_direction = horizontal_direction.is_equal_approx(Vector2.LEFT)
	
	# Avoid assigning the flip_h property when it's the same to avoid blinked animations
	if animated_sprite and is_left_direction != animated_sprite.flip_h:
		animated_sprite.flip_h = is_left_direction
	
	if event.is_action_pressed("jump") and jump_state:
		return finite_state_machine.change_state(jump_state)
		
	if event.is_action_pressed("dash") and dash_state:
		return finite_state_machine.change_state(dash_state)
	

func _physics_process(delta):
	var was_on_floor: bool = actor.body.is_on_floor()
	
	if horizontal_direction.is_zero_approx():
		actor.decelerate()
	else:
		actor.accelerate_in_direction(horizontal_direction)
		
	if not actor.body.is_on_floor():
		actor.apply_gravity()
	
	actor.move()
	
	if was_on_floor and not actor.body.is_on_floor() and falling_state:
		finite_state_machine.change_state(falling_state)
	

func translate_x_axis_to_vector(axis: float) -> Vector2:
	var horizontal_direction = Vector2.ZERO
	
	match axis:
		-1.0:
			horizontal_direction = Vector2.LEFT 
		1.0:
			horizontal_direction = Vector2.RIGHT
			
	return horizontal_direction
	
