extends CharacterBody2D

@onready var velocity_component_2d: VelocityComponent2D = $VelocityComponent2D

func _physics_process(delta):
	var input_axis = Input.get_axis("ui_left", "ui_right")

	apply_gravity()
	handle_horizontal_movement(input_axis)
	handle_jump()
	
	velocity_component_2d.move()
	
func apply_gravity():
	if not is_on_floor():
		velocity_component_2d.apply_gravity()

func handle_jump():
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity_component_2d.jump()
	
	
func handle_horizontal_movement(input_axis: float):
	var direction: Vector2 = Vector2.ZERO
	
	if input_axis == -1:
		direction = Vector2.LEFT
	if input_axis == 1:
		direction = Vector2.RIGHT
		
	if direction.is_equal_approx(Vector2.ZERO):
		velocity_component_2d.decelerate()
	else:
		velocity_component_2d.accelerate_in_direction(direction)

