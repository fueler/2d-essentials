class_name RunState extends State

@export var actor: VelocityComponent2D

@onready var jump_state = $"../JumpState"
@onready var idle_state = $"../IdleState"
@onready var falling_state = $"../FallingState"
@onready var dash_state = $"../DashState"

@onready var animation_player: AnimationPlayer = actor.body.get_node("AnimationPlayer")

func _ready():
	set_physics_process(false)
	
func _enter_state():
	animation_player.play("run")
	set_physics_process(true)

func _exit_state():
	set_physics_process(false)
	state_finished.emit()
	
func _physics_process(delta):
	var was_on_floor: bool = actor.body.is_on_floor()

	actor.move()
	
	if actor.velocity.is_zero_approx():
		get_parent().change_state(idle_state)
		return
	
	if Input.is_action_just_pressed("jump") and actor.can_jump():
		get_parent().change_state(jump_state)
		return
	
	if Input.is_action_just_pressed("dash") and actor.can_dash():
		get_parent().change_state(dash_state)
		return

	
	
	if was_on_floor and not actor.body.is_on_floor():
		get_parent().change_state(falling_state)
		return
	

