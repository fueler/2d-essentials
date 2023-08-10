class_name FallingState extends State

@export var actor: VelocityComponent2D
@onready var jump_state = $"../JumpState" as JumpState
@onready var idle_state = $"../IdleState" as IdleState
@onready var land_state = $"../LandState"


func _ready():
	set_physics_process(false)
	
func _enter_state() -> void:
	set_physics_process(true)
	
func _exit_state() -> void:
	set_physics_process(false)
	state_finished.emit()

func _physics_process(_delta):
	actor.body.handle_horizontal_movement()
	
	if actor.body.is_on_floor():
		get_parent().change_state(land_state)
	else:
		if Input.is_action_just_pressed("jump") and actor.can_jump():
			get_parent().change_state(jump_state)

