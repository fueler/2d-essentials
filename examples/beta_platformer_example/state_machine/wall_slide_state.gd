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
		return
		
	if Input.is_action_just_pressed("jump"):
		get_parent().change_state(jump_state)
		return
		
	if actor.can_wall_climb(actor.body.input_direction):
		get_parent().change_state(wall_climb_state)
		return
	
	actor.move()
