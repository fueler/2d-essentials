class_name FallingState extends State

@export var actor: VelocityComponent2D
@onready var jump_state = $"../JumpState" as JumpState
@onready var idle_state = $"../IdleState" as IdleState
@onready var land_state = $"../LandState"
@onready var wall_climb_state = $"../WallClimbState"

@onready var animation_player: AnimationPlayer = actor.body.get_node("AnimationPlayer")

func _ready():
	set_physics_process(false)
	
func _enter_state() -> void:
	animation_player.play("falling")
	set_physics_process(true)
	
func _exit_state() -> void:
	set_physics_process(false)
	state_finished.emit()

func _physics_process(_delta):
	actor.body.handle_horizontal_movement()
	
	if actor.body.is_on_floor():
		get_parent().change_state(land_state)
	else:
		if Input.is_action_just_pressed("jump") and actor.can_jump():
			get_parent().change_state(jump_state)
	
	if actor.wall_slide_enabled and actor.body.is_on_wall() and not actor.body.is_on_floor() and not actor.body.is_on_ceiling():
		get_parent().change_state(wall_climb_state)

