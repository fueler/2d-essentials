class_name JumpState extends State

@export var actor: VelocityComponent2D

@onready var falling_state = $"../FallingState"
@onready var wall_climb_state = $"../WallClimbState"

@onready var animation_player: AnimationPlayer = actor.body.get_node("AnimationPlayer")
@onready var animated_sprite: AnimatedSprite2D = actor.body.get_node("AnimatedSprite2D")

func _ready():
	set_physics_process(false)

func _enter_state() -> void:
	actor.jumped.connect(on_jump)
	actor.jump()
	actor.move()
	
	set_physics_process(true)

func _exit_state():
	actor.jumped.disconnect(on_jump)
	set_physics_process(false)
	state_finished.emit()

func _physics_process(_delta):
	actor.body.handle_horizontal_movement()
	
	if Input.is_action_just_pressed("jump"):
		actor.jump()
	
	if Input.is_action_just_released("jump"):
		short_jump()
		
	actor.move()

	if actor.velocity.y > 0:
		get_parent().change_state(falling_state)
		
	if actor.wall_slide_enabled and actor.body.is_on_wall() and not actor.body.is_on_floor() and not actor.body.is_on_ceiling():
		get_parent().change_state(wall_climb_state)


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
