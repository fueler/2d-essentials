class_name DashState extends AirState

func _ready():
	actor.dash_duration_timer.timeout.connect(on_dashed_finished)
	set_physics_process(false)
	
func _enter_state():
	set_physics_process(true)

func _exit_state():
	set_physics_process(false)

func _physics_process(delta):
	super._physics_process(delta)
		
	if Input.is_action_just_pressed("cancel_dash"):
		return actor.cancel_dash()
	
	if Input.is_action_just_pressed("dash"):
		actor.dash(input_direction)

	actor.move()

func on_dashed_finished():
	# This is because dash action it's used for rolling
	if finite_state_machine.current_state is DashState:
		finite_state_machine.change_state_by_name("FallingState")
	
