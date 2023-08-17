class_name AirState extends State

@export var actor: VelocityComponent2D
@onready var finite_state_machine = get_tree().get_first_node_in_group("finite_state_machine") as FiniteStateMachine

var horizontal_direction: Vector2 = Vector2.ZERO

func _unhandled_key_input(event):
	horizontal_direction = Helpers.translate_x_axis_to_vector(Input.get_axis("ui_left", "ui_right"))

func _physics_process(delta):
	actor.apply_gravity().accelerate_horizontally(horizontal_direction).move()
	
	if actor.can_wall_slide():
		return finite_state_machine.change_state_by_name("WallSlideState")
	
	


