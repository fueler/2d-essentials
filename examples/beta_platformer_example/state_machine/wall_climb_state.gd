class_name WallClimbState extends MoveState

@onready var input_direction: Vector2 = Vector2.ZERO

func _ready():
	set_physics_process(false)

func _enter_state():
	actor.velocity.y = 0
	set_physics_process(true)

func _exit_state():
	set_physics_process(false)

func _unhandled_input(event):
	input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()

	if event.is_action_pressed("jump"):
		return finite_state_machine.change_state_by_name("JumpState")

func _physics_process(_delta):
	actor.wall_climb(input_direction).move()
	
	if actor.body.is_on_floor():
		return finite_state_machine.change_state_by_name("IdleState")
		
	if actor.can_wall_slide():
		return finite_state_machine.change_state_by_name("WallSlideState")
		
	if not actor.body.is_on_wall():
		return finite_state_machine.change_state_by_name("FallingState")

