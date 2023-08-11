class_name IdleState extends State

@export var actor: VelocityComponent2D

@onready var jump_state = $"../JumpState" as JumpState
@onready var run_state = $"../RunState" as RunState
@onready var falling_state = $"../FallingState"

@onready var animation_player: AnimationPlayer = actor.body.get_node("AnimationPlayer")
@onready var animated_sprite: AnimatedSprite2D = actor.body.get_node("AnimatedSprite2D")


func _ready():
	set_physics_process(false)

func _enter_state():
	animation_player.play("idle")
	
	set_physics_process(true)	

func _exit_state():
	set_physics_process(false)
	state_finished.emit()
	
func _physics_process(delta):
	actor.body.handle_horizontal_movement()
	
	if not actor.body.horizontal_direction.is_zero_approx():
		get_parent().change_state(run_state)
	
	if Input.is_action_just_pressed("jump") and actor.can_jump():
		get_parent().change_state(jump_state)
		
