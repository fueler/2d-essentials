class_name WallState extends State

@export var actor: VelocityComponent2D
@onready var finite_state_machine = get_tree().get_first_node_in_group("finite_state_machine") as FiniteStateMachine

var input_direction: Vector2 = Vector2.ZERO

func _unhandled_input(event):
	input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	
	if event.is_action_pressed("jump"):
		return finite_state_machine.change_state_by_name("JumpState")
