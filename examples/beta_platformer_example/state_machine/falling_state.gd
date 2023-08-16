class_name FallingState extends MoveState

func _ready():
	set_physics_process(false)

func _enter_state() -> void:
	if animation_player:
		animation_player.play("falling")
		
	set_physics_process(true)

func _exit_state() -> void:
	set_physics_process(false)

func _physics_process(delta):
	actor.apply_gravity().move()
		
	if actor.body.is_on_floor():
		return finite_state_machine.change_state(land_state)
	
		
