class_name GroundState extends State

@export var actor: VelocityComponent2D
@onready var finite_state_machine = get_tree().get_first_node_in_group("finite_state_machine") as FiniteStateMachine

var horizontal_direction: Vector2 = Vector2.ZERO

func _unhandled_key_input(event):
	horizontal_direction = Helpers.translate_x_axis_to_vector(Input.get_axis("ui_left", "ui_right"))

func _physics_process(delta):
	var was_on_floor: bool = actor.body.is_on_floor()
	
	if not was_on_floor:
		actor.apply_gravity()
		
	if horizontal_direction.is_zero_approx():
		actor.decelerate()
	else:
		actor.accelerate_horizontally(horizontal_direction)
	
	actor.move()
	
		
	if was_on_floor and not actor.body.is_on_floor():
		finite_state_machine.change_state_by_name("FallingState")
	

