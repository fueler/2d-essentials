class_name DashState extends MoveState

func _ready():
	actor.dash_duration_timer.timeout.connect(on_dash_finished)

	set_physics_process(false)

func _enter_state():
	set_physics_process(true)

func _exit_state():
	set_physics_process(false)

func _physics_process(delta):
	if Input.is_action_just_pressed("dash") and actor.can_dash():
		actor.dash(actor.body.input_direction).move()

	super._physics_process(delta)
	
	
func on_dash_finished():
	finite_state_machine.change_state_by_name("FallingState")
