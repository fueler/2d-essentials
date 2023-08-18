class_name GroundState extends State

@export var actor: VelocityComponent2D
@onready var finite_state_machine = get_tree().get_first_node_in_group("finite_state_machine") as FiniteStateMachine

var horizontal_direction: Vector2 = Vector2.ZERO

func _unhandled_key_input(event):
	horizontal_direction = Helpers.translate_x_axis_to_vector(Input.get_axis("ui_left", "ui_right"))
	
	if event.is_action_pressed("jump") and can_transition_to_jump():
		return finite_state_machine.change_state_by_name("JumpState")
	
	if event.is_action_pressed("dash") and can_transition_to_rolling():
		return finite_state_machine.change_state_by_name("RollingState")
	
func _physics_process(delta):
	var was_on_floor: bool = actor.body.is_on_floor()
	
	if not was_on_floor:
		actor.apply_gravity()
		
	if horizontal_direction.is_zero_approx():
		actor.decelerate()
	else:
		actor.accelerate_in_direction(horizontal_direction, true)
	
	actor.move()
	
	if was_on_floor and not actor.body.is_on_floor():
		return finite_state_machine.change_state_by_name("FallingState")
		
	
func can_transition_to_jump() -> bool:
	if actor.coyote_timer.time_left > 0:
		return true
	
	return not finite_state_machine.current_state is AirState
	
func can_transition_to_rolling() -> bool:
	return not horizontal_direction.is_zero_approx() and actor.velocity.x != 0 \
		and actor.can_dash() \
		and not finite_state_machine.current_state is AirState \
		and not finite_state_machine.current_state is WallState 
