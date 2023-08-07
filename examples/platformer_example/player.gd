extends CharacterBody2D

@onready var velocity_component_2d: VelocityComponent2D = $VelocityComponent2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var camera_2d = $Camera2D
@onready var shake_camera_component_2d = $Camera2D/ShakeCameraComponent2D

func _process(delta):
	if Input.is_action_just_pressed("shake"):
		$Camera2D/ShakeCameraComponent2D.shake() 

		
func _physics_process(delta):
	var input_axis = Input.get_axis("ui_left", "ui_right")
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	var horizontal_direction: Vector2 = translate_x_axis_to_vector(input_axis)
	
	
	apply_gravity()
	handle_jump()
	handle_wall_sliding()
	handle_wall_jump(horizontal_direction)
	handle_horizontal_movement(horizontal_direction)
	handle_dash(input_direction)
	update_animations(input_axis)

	velocity_component_2d.move()

func apply_gravity():
	if not is_on_floor():
		velocity_component_2d.apply_gravity()

func handle_jump():
	if Input.is_action_just_pressed("jump"):
		velocity_component_2d.jump()
		
	if Input.is_action_just_released("jump"):
		var actual_velocity_y = velocity_component_2d.velocity.y
		var new_jump_velocity = velocity_component_2d.jump_velocity / 2
	
		if actual_velocity_y < new_jump_velocity or velocity_component_2d.is_inverted_gravity and actual_velocity_y > new_jump_velocity:
			velocity_component_2d.velocity.y = new_jump_velocity


func handle_wall_jump(direction: Vector2):
	if Input.is_action_just_pressed("jump"):
		velocity_component_2d.wall_jump(direction)
	
func handle_wall_sliding():
	velocity_component_2d.wall_sliding()
	
func handle_horizontal_movement(direction: Vector2):
	if direction.is_equal_approx(Vector2.ZERO):
		velocity_component_2d.decelerate()
	else:
		velocity_component_2d.accelerate_in_direction(direction)
		
		
func translate_x_axis_to_vector(input_axis: float) -> Vector2:
	var horizontal_direction: Vector2 = Vector2.ZERO
	
	match input_axis:
		-1.0:
			horizontal_direction = Vector2.LEFT
		1.0:
			horizontal_direction = Vector2.RIGHT
			
	return horizontal_direction
	

func handle_dash(direction: Vector2):
	if Input.is_action_just_pressed("dash"):
		velocity_component_2d.dash(direction)
		
		
func update_animations(input_axis):
	if input_axis == 0:
		animated_sprite_2d.play('idle')
	else:
		animated_sprite_2d.play("run")
		animated_sprite_2d.flip_h = input_axis < 0
		
	if not is_on_floor():
		animated_sprite_2d.play("jump")


func _on_invert_gravity_area_body_entered(body):
	velocity_component_2d.invert_gravity()
	animated_sprite_2d.flip_v = velocity_component_2d.is_inverted_gravity
	collision_shape_2d.position.y = -collision_shape_2d.position.y

	#The character needs a little push so that it does not collide again after the first collision.
	body.velocity.y += 50 if velocity_component_2d.is_inverted_gravity else -50
	body.move_and_slide() 

