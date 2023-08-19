extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var velocity_component_2d = $VelocityComponent2D as VelocityComponent2D
@onready var camera_2d = $Camera2D

var input_axis: float = 0.0
var input_direction: Vector2 = Vector2.ZERO
var horizontal_direction: Vector2 = Vector2.ZERO
var is_left_direction: bool = false

func _ready():
	camera_2d.make_current()
	
func _unhandled_input(event):
	input_axis = Input.get_axis("ui_left", "ui_right")
	input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	horizontal_direction = _translate_x_axis_to_vector(input_axis)


func _process(delta):
	is_left_direction = velocity_component_2d.last_faced_direction.is_equal_approx(Vector2.LEFT) or horizontal_direction.is_equal_approx(Vector2.LEFT)

	if animated_sprite_2d and is_left_direction != animated_sprite_2d.flip_h:
		animated_sprite_2d.flip_h = is_left_direction

func _physics_process(delta):
	if not is_on_floor():
		velocity_component_2d.apply_gravity()

	if horizontal_direction.is_zero_approx() and is_on_floor():
		velocity_component_2d.decelerate()
	else:
		velocity_component_2d.accelerate_in_direction(horizontal_direction, true)
	
	if Input.is_action_just_pressed("jump"):
		if velocity_component_2d.can_wall_jump():
			velocity_component_2d.wall_jump(horizontal_direction)
		else:
			velocity_component_2d.jump()
			
	if Input.is_action_just_pressed("dash"):
		velocity_component_2d.dash(input_direction)

			
	velocity_component_2d.wall_climb(input_direction).wall_slide().move()

func _translate_x_axis_to_vector(axis: float) -> Vector2:
	var horizontal_direction = Vector2.ZERO
	match axis:
		-1.0:
			horizontal_direction = Vector2.LEFT 
		1.0:
			horizontal_direction = Vector2.RIGHT
			
	return horizontal_direction
		
