class_name AirState extends State

@export var actor: VelocityComponent2D
@onready var finite_state_machine = get_tree().get_first_node_in_group("finite_state_machine") as FiniteStateMachine

var horizontal_direction: Vector2 = Vector2.ZERO
var input_direction: Vector2 = Vector2.ZERO

func _unhandled_input(event):
	horizontal_direction = Helpers.translate_x_axis_to_vector(Input.get_axis("ui_left", "ui_right"))
	input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
		
	if event.is_action_pressed("dash") and can_transition_to_dash():
		return finite_state_machine.change_state_by_name("DashState")
	

func _physics_process(delta):
	actor.apply_gravity().accelerate_horizontally(horizontal_direction).move()
	
	if actor.can_wall_slide():
		return finite_state_machine.change_state_by_name("WallSlideState")
	
	
func can_transition_to_dash() -> bool:
	return actor.can_dash() \
		and finite_state_machine.current_state is AirState \
		and not finite_state_machine.current_state_name_is("DashState") 
	
