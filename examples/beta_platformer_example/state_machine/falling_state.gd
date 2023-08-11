class_name FallingState extends State

@export var actor: VelocityComponent2D
@onready var jump_state = $"../JumpState" as JumpState
@onready var idle_state = $"../IdleState" as IdleState
@onready var land_state = $"../LandState" as LandState
@onready var wall_slide_state = $"../WallSlideState"
@onready var dash_state = $"../DashState"

@onready var animation_player: AnimationPlayer = actor.body.get_node("AnimationPlayer")

func _ready():
	set_physics_process(false)
	
func _enter_state() -> void:
	animation_player.play("falling")
	set_physics_process(true)
	
func _exit_state() -> void:
	set_physics_process(false)

func _physics_process(_delta):	
	if actor.body.is_on_floor():
		get_parent().change_state(land_state)
	else:
		if Input.is_action_just_pressed("jump") and actor.can_jump():
			get_parent().change_state(jump_state)
			return
			
		if Input.is_action_just_pressed("dash") and actor.can_dash():
			get_parent().change_state(dash_state)
			return
	
	if actor.can_wall_slide():
		get_parent().change_state(wall_slide_state)
		return

