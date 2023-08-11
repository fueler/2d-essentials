class_name DashState extends State

@export var actor: VelocityComponent2D
@onready var falling_state = $"../FallingState"

func _ready():
	set_physics_process(false)
	
func _enter_state():
	set_physics_process(true)
	
func _exit_state():
	set_physics_process(false)

func _physics_process(delta):
	actor.dash(actor.body.input_direction)
	
	get_parent().change_state(falling_state)
