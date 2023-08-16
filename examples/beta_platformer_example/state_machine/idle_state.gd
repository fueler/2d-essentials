class_name IdleState extends MoveState


func _ready():
	set_physics_process(false)
	
func _enter_state():
	if animation_player:
		animation_player.play("idle")
	
	actor.velocity = Vector2.ZERO
	
	set_physics_process(true)	

func _exit_state():
	set_physics_process(false)

func _physics_process(delta):
	if not horizontal_direction.is_zero_approx():
		finite_state_machine.change_state(run_state)
