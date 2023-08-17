extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var velocity_component_2d = $VelocityComponent2D as VelocityComponent2D
@onready var finite_state_machine = $FiniteStateMachine as FiniteStateMachine

var input_axis: float = 0.0
var input_direction: Vector2 = Vector2.ZERO
var horizontal_direction: Vector2 = Vector2.ZERO
var is_left_direction: bool = false

func _ready():
	finite_state_machine.state_changed.connect(on_state_changed)
	animation_player.animation_finished.connect(on_animation_finished)

	update_animations(finite_state_machine.current_state)

func _unhandled_key_input(event):
	input_axis = Input.get_axis("ui_left", "ui_right")
	input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	horizontal_direction = _translate_x_axis_to_vector(input_axis)


func _process(delta):
	is_left_direction = velocity_component_2d.last_faced_direction.is_equal_approx(Vector2.LEFT) or horizontal_direction.is_equal_approx(Vector2.LEFT)

	if animated_sprite_2d and is_left_direction != animated_sprite_2d.flip_h:
		animated_sprite_2d.flip_h = is_left_direction
#
#func _physics_process(delta):
#	if Input.is_action_just_pressed("dash"):
#		velocity_component_2d.dash(input_direction)
#
#	if not is_on_floor():
#		velocity_component_2d.apply_gravity()
#
#	if horizontal_direction.is_zero_approx() and is_on_floor():
#		velocity_component_2d.decelerate()
#	else:
#		if not is_on_wall():
#			velocity_component_2d.accelerate_in_direction(horizontal_direction)
#
#	if Input.is_action_just_pressed("jump"):
#		if velocity_component_2d.can_wall_jump():
#			velocity_component_2d.wall_jump(horizontal_direction)
#		else:
#			velocity_component_2d.jump()
#
#	velocity_component_2d.wall_climb(input_direction).wall_slide().move()


func update_animations(state: State):
	match state.name:
		"IdleState": 
			animation_player.play("idle")
		"RunState":
			animation_player.play("run")
		"LandState":
			animation_player.play("land")
		"JumpState":
			animation_player.play("jump")
		"FallingState":
			animation_player.play("falling")
		"WallSlideState":
			animation_player.play("wall_slide")
		"WallClimbState":
			animation_player.play("wall_climb")


func _translate_x_axis_to_vector(axis: float) -> Vector2:
	var horizontal_direction = Vector2.ZERO
	match axis:
		-1.0:
			horizontal_direction = Vector2.LEFT 
		1.0:
			horizontal_direction = Vector2.RIGHT
			
	return horizontal_direction
		
func on_state_changed(_current_state: State, new_state: State):
	update_animations(new_state)
	print(_current_state.name, new_state.name)

func on_animation_finished(animation_name: String):
	if animation_name == "land" and finite_state_machine.current_state_name_is("LandState"):
		finite_state_machine.change_state_by_name("IdleState")

