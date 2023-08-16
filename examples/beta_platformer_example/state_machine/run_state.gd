class_name RunState extends MoveState


func _ready():
	set_physics_process(false)
	
func _enter_state():
	if animation_player:
		animation_player.play("run")

	set_physics_process(true)

func _exit_state():
	set_physics_process(false)
	
func _physics_process(delta):
	super._physics_process(delta)
	
	if actor.velocity.is_zero_approx() and idle_state:
		return finite_state_machine.change_state(idle_state)
	

