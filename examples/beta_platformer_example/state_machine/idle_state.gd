class_name IdleState extends MoveState

func _ready():
	set_physics_process(false)
	
func _enter_state():
	actor.velocity = Vector2.ZERO
	
	set_physics_process(true)	

func _exit_state():
	set_physics_process(false)

func _physics_process(delta):
	super._physics_process(delta)
	
	if not actor.body.horizontal_direction.is_zero_approx():
		return finite_state_machine.change_state_by_name("RunState")
