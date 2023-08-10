class_name LandState extends State

@export var actor: VelocityComponent2D
@export var animation_player: AnimationPlayer

@onready var idle_state = $"../IdleState"
@onready var run_state = $"../RunState"
@onready var jump_state = $"../JumpState"

func _ready():
	set_physics_process(false)

func _enter_state():
	animation_player.animation_finished.connect(on_land_animation_finished)
	animation_player.play("land")
	set_physics_process(true)

func _exit_state():
	set_physics_process(false)
	animation_player.animation_finished.disconnect(on_land_animation_finished)
	state_finished.emit()

func _physics_process(delta):
	actor.body.handle_horizontal_movement()
	actor.move()
	
	if not actor.velocity.is_zero_approx():
		animation_player.stop()
		get_parent().change_state(run_state)
		
	if Input.is_action_just_pressed("jump"):
		animation_player.stop()
		get_parent().change_state(jump_state)
		

func on_land_animation_finished(name):
	if name == "land":
		get_parent().change_state(idle_state)
