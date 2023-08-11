class_name WallClimbState extends State

@export var actor: VelocityComponent2D
@onready var animation_player: AnimationPlayer = actor.body.get_node("AnimationPlayer")
@onready var idle_state = $"../IdleState"

func _ready():
	set_physics_process(false)


func _enter_state():
	animation_player.play("wall_slide")
	set_physics_process(true)
	
func _exit_state():
	set_physics_process(false)
	state_finished.emit()
	
func _physics_process(delta):
	actor.body.handle_horizontal_movement()
	actor.wall_sliding()
	actor.move()
	
	if actor.body.is_on_floor():
		get_parent().change_state(idle_state)
		
	if Input.is_action_just_pressed("jump"):
		actor.wall_jump(actor.body.horizontal_direction)
