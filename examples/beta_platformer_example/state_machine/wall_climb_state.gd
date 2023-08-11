class_name WallClimbState extends State

@export var actor: VelocityComponent2D

@onready var animation_player: AnimationPlayer = actor.body.get_node("AnimationPlayer")
@onready var idle_state = $"../IdleState" as IdleState
@onready var jump_state = $"../JumpState" as JumpState
@onready var wall_slide_state = $"../WallSlideState" as WallSlideState

func _ready():
	set_physics_process(false)

func _enter_state():
	animation_player.play("wall_climb")
	set_physics_process(true)
	
func _exit_state():
	actor.is_wall_climbing = false
	actor.gravity_enabled = true

	set_physics_process(false)

func _physics_process(delta):
	actor.wall_climb(actor.body.input_direction)

	if actor.body.is_on_floor():
		get_parent().change_state(idle_state)
		
	if Input.is_action_just_pressed("jump") and actor.can_wall_jump():
		get_parent().change_state(jump_state)
		return
		
	if actor.can_wall_slide():
		get_parent().change_state(wall_slide_state)

	actor.move()
