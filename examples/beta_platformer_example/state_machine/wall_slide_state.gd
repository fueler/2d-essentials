class_name WallSlideState extends State

@export var actor: VelocityComponent2D

@onready var animation_player: AnimationPlayer = actor.body.get_node("AnimationPlayer")
@onready var idle_state = $"../IdleState"
@onready var jump_state = $"../JumpState"
@onready var wall_climb_state = $"../WallClimbState"

func _ready():
	set_physics_process(false)


func _enter_state():
	animation_player.play("wall_slide")
	set_physics_process(true)
	
func _exit_state():
	set_physics_process(false)
	state_finished.emit()
	
func _physics_process(delta):
	actor.wall_sliding()
	
	if actor.body.is_on_floor():
		get_parent().change_state(idle_state)
		
	if Input.is_action_just_pressed("jump"):
		get_parent().change_state(jump_state)
		
	if (actor.body.input_direction.is_equal_approx(Vector2.UP) or actor.body.input_direction.is_equal_approx(Vector2.DOWN)) and actor.wall_climb_enabled:
		get_parent().change_state(wall_climb_state)
	
	actor.move()
