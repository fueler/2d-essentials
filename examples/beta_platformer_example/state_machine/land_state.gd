class_name LandState extends State

@export var actor: VelocityComponent2D
@export var animation_player: AnimationPlayer

@onready var idle_state = $"../IdleState"
@onready var run_state = $"../RunState"
@onready var jump_state = $"../JumpState"

func _ready():
	set_physics_process(false)
	animation_player.animation_finished.connect(on_land_animation_finished)

func _enter_state():
	animation_player.play("land")
	set_physics_process(true)

func _exit_state():
	set_physics_process(false)

func _physics_process(delta):
	actor.move()
	
	if not actor.body.horizontal_direction.is_zero_approx():
		get_parent().change_state(run_state)
		
	if Input.is_action_just_pressed("jump"):
		get_parent().change_state(jump_state)


func on_land_animation_finished(name):
	if name == "land":
		get_parent().change_state(idle_state)
