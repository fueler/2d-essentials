extends CharacterBody2D

@onready var velocity_component_2d: VelocityComponent2D = $VelocityComponent2D
@onready var animated_sprite_2d = $AnimatedSprite2D

func _physics_process(delta):
	var input_axis = Input.get_axis("ui_left", "ui_right")

	apply_gravity()
	handle_horizontal_movement(input_axis)
	handle_jump()
	update_animations(input_axis)
	
	velocity_component_2d.move()
	
func apply_gravity():
	if not is_on_floor():
		velocity_component_2d.apply_gravity()

func handle_jump():
	if Input.is_action_just_pressed("jump"):
		velocity_component_2d.jump()
	
	
func handle_horizontal_movement(input_axis: float):
	var direction: Vector2 = Vector2.ZERO
	
	match input_axis:
		-1.0:
			direction = Vector2.LEFT
		1.0:
			direction = Vector2.RIGHT

	if direction.is_equal_approx(Vector2.ZERO):
		velocity_component_2d.decelerate()
	else:
		velocity_component_2d.accelerate_in_direction(direction)


func update_animations(input_axis):
	if input_axis == 0:
		animated_sprite_2d.play('idle')
	else:
		animated_sprite_2d.play("run")
		animated_sprite_2d.flip_h = input_axis < 0
		
	if not is_on_floor():
		animated_sprite_2d.play("jump")
