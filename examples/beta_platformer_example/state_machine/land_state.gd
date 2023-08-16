class_name LandState extends MoveState


func _ready():
	set_physics_process(false)
	if animation_player:
		animation_player.animation_finished.connect(on_land_animation_finished)

func _enter_state():
	animation_player.play("land")
	
	if horizontal_direction.is_zero_approx():
		actor.velocity = Vector2.ZERO
		
	set_physics_process(true)

func _exit_state():
	set_physics_process(false)

func _physics_process(delta):
	if not horizontal_direction.is_zero_approx():
		return finite_state_machine.change_state(run_state)

func on_land_animation_finished(animation_name: String):
	if animation_name == "land":
		finite_state_machine.change_state(idle_state)
