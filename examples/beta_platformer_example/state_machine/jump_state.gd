class_name JumpState extends State

@export var actor: VelocityComponent2D

@onready var falling_state = $"../FallingState" as FallingState
@onready var wall_slide_state = $"../WallSlideState" as WallSlideState
@onready var dash_state = $"../DashState"

@onready var animation_player: AnimationPlayer = actor.body.get_node("AnimationPlayer")
@onready var animated_sprite: AnimatedSprite2D = actor.body.get_node("AnimatedSprite2D")

func _ready():
	actor.jumped.connect(on_jump)
	actor.wall_jumped.connect(on_jump)
	
	set_physics_process(false)

func _enter_state() -> void:
	if actor.can_wall_jump():
		actor.wall_jump(actor.body.horizontal_direction)
	else:
		actor.jump()
		
	set_physics_process(true)

func _exit_state():
	set_physics_process(false)
	state_finished.emit()

func _physics_process(_delta):
	if Input.is_action_just_pressed("dash") and actor.allowed_to_dash():
		get_parent().change_state(dash_state)
		
	if Input.is_action_just_pressed("jump"):
		actor.jump()
	
	if Input.is_action_just_released("jump"):
		short_jump()
	
	actor.move()

	if actor.velocity.y > 0:
		get_parent().change_state(falling_state)
		
	if actor.can_wall_slide():
		get_parent().change_state(wall_slide_state)
		

func short_jump():
	var actual_velocity_y = actor.velocity.y
	var new_jump_velocity = actor.jump_velocity / 2

	if actor.is_inverted_gravity:
		if actual_velocity_y > new_jump_velocity:
			actor.velocity.y = new_jump_velocity
	else:
		if actual_velocity_y < new_jump_velocity:
			actor.velocity.y = new_jump_velocity

func on_jump():
	animation_player.stop()
	animation_player.play("jump")
