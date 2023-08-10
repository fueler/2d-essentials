class_name RunState extends State

@export var actor: VelocityComponent2D

@onready var jump_state = $"../JumpState"
@onready var idle_state = $"../IdleState"

@onready var animation_player: AnimationPlayer = actor.body.get_node("AnimationPlayer")
@onready var animated_sprite: AnimatedSprite2D = actor.body.get_node("AnimatedSprite2D")

func _ready():
	set_physics_process(false)
	
func _enter_state():
	animation_player.play("run")
	set_physics_process(true)

func _exit_state():
	set_physics_process(false)
	state_finished.emit()
	
func _physics_process(delta):
	actor.body.handle_horizontal_movement()
	actor.move()

	animated_sprite.flip_h = actor.velocity.x < 0	

	if actor.velocity.is_zero_approx():
		get_parent().change_state(idle_state)
	
	if Input.is_action_just_pressed("jump") and actor.can_jump():
		get_parent().change_state(jump_state)
		
