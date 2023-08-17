class_name FallingState extends MoveState

func _ready():
	set_physics_process(false)

func _enter_state() -> void:
	set_physics_process(true)

func _exit_state() -> void:
	set_physics_process(false)

func _physics_process(delta):
	super._physics_process(delta)
		
	if actor.body.is_on_floor():
		return finite_state_machine.change_state_by_name("LandState")
	
	if actor.can_wall_slide():
		return finite_state_machine.change_state_by_name("WallSlideState")
		
