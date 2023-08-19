extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var velocity_component_2d = $VelocityComponent2D as VelocityComponent2D
@onready var finite_state_machine = $FiniteStateMachine as FiniteStateMachine

var is_left_direction: bool = false

func _ready():
	finite_state_machine.state_changed.connect(on_state_changed)
	animation_player.animation_finished.connect(on_animation_finished)
	
	update_animations(finite_state_machine.current_state)

func _process(delta):
	is_left_direction = velocity_component_2d.last_faced_direction.is_equal_approx(Vector2.LEFT)
	
	if animated_sprite_2d and is_left_direction != animated_sprite_2d.flip_h:
		animated_sprite_2d.flip_h = is_left_direction
		
#
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
		"RollingState":
			animation_player.play("roll")
		"FallingState":
			animation_player.play("falling")
		"WallSlideState":
			animation_player.play("wall_slide")
		"WallClimbState":
			animation_player.play("wall_climb")


func on_state_changed(_current_state: State, new_state: State):
	update_animations(new_state)

func on_animation_finished(animation_name: String):
	if animation_name == "land" and finite_state_machine.current_state_name_is("LandState"):
		finite_state_machine.change_state_by_name("IdleState")
		
	if animation_name == "roll" and finite_state_machine.current_state_name_is("RollingState"):
		finite_state_machine.change_state_by_name("IdleState")

