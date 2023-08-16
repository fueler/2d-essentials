class_name JumpState extends MoveState


func _ready():
	actor.jumped.connect(on_jump)
	actor.wall_jumped.connect(on_jump)

	set_physics_process(false)

func _enter_state() -> void:
	set_physics_process(true)

func _exit_state():
	set_physics_process(false)

func _physics_process(delta):
	if Input.is_action_just_pressed("jump"):
		if actor.can_wall_jump():
			actor.wall_jump(horizontal_direction)
		else:
			actor.jump()

	if Input.is_action_just_released("jump"):
		short_jump()

	actor.apply_gravity().move()
	
	if actor.velocity.y > 0 or (actor.is_inverted_gravity and actor.velocity.y < 0):
		return finite_state_machine.change_state_by_name("FallingState")
	
	if actor.can_wall_slide():
		return finite_state_machine.change_state_by_name("WallSlideState")

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
	if animation_player:
		animation_player.stop()
		animation_player.play("jump")
