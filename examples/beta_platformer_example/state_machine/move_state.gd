class_name MoveState extends State

@export var actor: VelocityComponent2D
@onready var finite_state_machine = get_tree().get_first_node_in_group("finite_state_machine") as FiniteStateMachine

func _unhandled_input(event):
	if event.is_action_pressed("dash") and actor.can_dash() and not actor.body.input_direction.is_zero_approx():
		return finite_state_machine.change_state_by_name("DashState")
		
	if event.is_action_pressed("jump"):
		return finite_state_machine.change_state_by_name("JumpState")

func _physics_process(delta):
	var was_on_floor: bool = actor.body.is_on_floor()
	
	if actor.body.horizontal_direction.is_zero_approx() and was_on_floor:
		actor.decelerate()
	else:
		if not actor.body.is_on_wall():
			actor.accelerate_in_direction(actor.body.horizontal_direction)
		
	if not was_on_floor:
		actor.apply_gravity()
	
	actor.move()
	
	if was_on_floor and not actor.body.is_on_floor():
		finite_state_machine.change_state_by_name("FallingState")
	

