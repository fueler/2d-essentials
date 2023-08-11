class_name DashState extends State

@export var actor: VelocityComponent2D
@onready var falling_state = $"../FallingState"
@onready var idle_state = $"../IdleState"

@onready var animation_player: AnimationPlayer = actor.body.get_node("AnimationPlayer")
@onready var animated_sprite: AnimatedSprite2D = actor.body.get_node("AnimatedSprite2D")

func _ready():
	actor.dashed.connect(on_dashed)
	animation_player.animation_finished.connect(on_animation_finished)
	set_physics_process(false)
	
func _enter_state():
	set_physics_process(true)
	actor.dash(actor.body.input_direction)

func _exit_state():
	set_physics_process(false)
	
func _physics_process(delta):
	if Input.is_action_just_pressed("dash") and actor.allowed_to_dash():
		actor.dash(actor.body.input_direction)
	
	actor.move()

func on_animation_finished(name):
	if name == 'roll':
		get_parent().change_state(idle_state)
		
func on_dashed():
	if actor.body.is_on_floor():
		animation_player.stop()
		animation_player.play("roll")
	else:
		await get_tree().create_timer(actor.dash_gravity_time_disabled).timeout
		get_parent().change_state(falling_state)
	
	
	
