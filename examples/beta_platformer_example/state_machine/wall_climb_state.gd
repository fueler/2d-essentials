class_name WallClimbState extends State

@export var actor: VelocityComponent2D

@onready var animation_player: AnimationPlayer = actor.body.get_node("AnimationPlayer")
@onready var idle_state = $"../IdleState"
@onready var jump_state = $"../JumpState"
@onready var wall_slide_state = $"../WallSlideState"

func _ready():
	set_physics_process(false)

func _enter_state():
	animation_player.play("wall_climb")
	set_physics_process(true)
	
func _exit_state():
	actor.is_wall_climbing = false
	set_physics_process(false)

func _physics_process(delta):
	actor.wall_climb(actor.body.input_direction)
	actor.move()
	
	if actor.body.is_on_floor():
		get_parent().change_state(idle_state)
		
	if Input.is_action_just_pressed("jump"):
		get_parent().change_state(jump_state)

	if not actor.is_wall_climbing:
		get_parent().change_state(wall_slide_state)
