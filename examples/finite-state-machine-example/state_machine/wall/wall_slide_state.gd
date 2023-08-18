class_name WallSlideState extends WallState


func _ready():
	set_physics_process(false)

func _enter_state():
	actor.velocity.y = actor.wall_slide_gravity
	set_physics_process(true)
	
func _exit_state():
	set_physics_process(false)

func _physics_process(delta):	
	actor.wall_slide().move()
	
	if actor.body.is_on_floor():
		return finite_state_machine.change_state_by_name("IdleState")
	
	if actor.can_wall_climb(input_direction):
		return finite_state_machine.change_state_by_name("WallClimbState")

	if not actor.can_wall_slide():
		actor.velocity.x = 0
		return finite_state_machine.change_state_by_name("FallingState")
