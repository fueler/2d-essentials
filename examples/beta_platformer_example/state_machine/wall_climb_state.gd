class_name WallClimbState extends WallState

func _ready():
	set_physics_process(false)

func _enter_state():
	actor.velocity.y = 0
	set_physics_process(true)

func _exit_state():
	set_physics_process(false)

func _physics_process(delta):
	actor.wall_climb(input_direction).move()

	if actor.body.is_on_floor():
		return finite_state_machine.change_state_by_name("IdleState")
		
	if actor.can_wall_slide():
		return finite_state_machine.change_state_by_name("WallSlideState")
		
	if not actor.body.is_on_wall():
		return finite_state_machine.change_state_by_name("FallingState")

