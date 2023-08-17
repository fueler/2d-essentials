class_name RollingState extends GroundState


func _ready():
	set_physics_process(false)
	

func _enter_state():
	actor.decelerate(true).dash(horizontal_direction)
	set_physics_process(true)

func _exit_state():
	set_physics_process(false)


func _physics_process(delta):
	var was_on_floor: bool = actor.body.is_on_floor()
	
	actor.move()
	
	if was_on_floor and not actor.body.is_on_floor():
		return finite_state_machine.change_state_by_name("FallingState")
	
	
