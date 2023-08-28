class_name GodotEssentialsPlatformerMovementComponent extends GodotEssentialsMotion

signal gravity_changed(enabled: bool)
signal inverted_gravity(inverted: bool)
signal jumped(position: Vector2)
signal wall_jumped(normal: Vector2, position: Vector2)
signal allowed_jumps_reached(jump_positions: Array[Vector2])
signal jumps_restarted
signal coyote_time_started

## The maximum vertical velocity while falling to control fall speed
@export_group("Gravity")
@export var MAXIMUM_FALL_VELOCITY: float = 200.0
@export var DEFAULT_GRAVITY_SUSPEND_DURATION: float = 2.0


@export_group("Jump")
## The maximum height the character can reach
@export var jump_height: float = 85:
	set(value):
		jump_height = value
		jump_velocity = _calculate_jump_velocity(jump_height, jump_time_to_peak)
		jump_gravity = _calculate_jump_gravity(jump_height, jump_time_to_peak )
		fall_gravity = _calculate_fall_gravity(jump_height, jump_time_to_fall)
	get:
		return jump_height
		
## Time it takes to reach the maximum jump height
@export var jump_time_to_peak: float = 0.4:
	set(value):
		jump_time_to_peak = value
		jump_velocity = _calculate_jump_velocity(jump_height, jump_time_to_peak)
		jump_gravity = _calculate_jump_gravity(jump_height, jump_time_to_peak )
	get:
		return jump_time_to_peak
		
## Time it takes to reach the floor after jump
@export var jump_time_to_fall: float = 0.4:
	set(value):
		jump_time_to_fall = value
		fall_gravity = _calculate_fall_gravity(jump_height, jump_time_to_fall)
	get:
		return jump_time_to_fall
		
## The value represents a velocity threshold that determines whether the character can jump
@export var jump_velocity_threshold: float = 300.0
## Jumps allowed to perform in a row
@export var allowed_jumps : int = 1
## Reduced amount of jump effectiveness at each iteration
@export var height_reduced_by_jump : int = 0

## Enable the coyote jump
@export var coyote_jump_enabled: bool = true
## The time window this jump can be executed when the character is not on the floor
@export var coyote_jump_time_window: float = 0.1

@onready var jump_velocity: float = _calculate_jump_velocity()
@onready var jump_gravity: float =  _calculate_jump_gravity()
@onready var fall_gravity: float =  _calculate_fall_gravity()


var gravity_enabled: bool = true:
	set(value):
		if value != gravity_enabled:
			gravity_changed.emit(value)
			
		gravity_enabled = value

var is_inverted_gravity: bool = false:
	set(value):
		if value != is_inverted_gravity:
			inverted_gravity.emit(value)
			
		is_inverted_gravity = value

var suspend_gravity_timer: Timer
var jump_queue: Array[Vector2] = []

func _ready():
	super._ready()
	_create_suspend_gravity_timer()


func accelerate_horizontally(direction: Vector2, delta: float =  get_physics_process_delta_time()) -> GodotEssentialsPlatformerMovementComponent:
	facing_direction = _normalize_vector(direction)
	
	if not direction.is_zero_approx():
		last_faced_direction = direction
		
		if ACCELERATION > 0:
			velocity.x = lerp(velocity.x, direction.x * MAX_SPEED, (ACCELERATION / 100) * delta)
		else:
			velocity.x = direction.x * MAX_SPEED
		
	return self


func decelerate_horizontally(delta: float = get_physics_process_delta_time(), force_stop: bool = false) -> GodotEssentialsPlatformerMovementComponent:
	if force_stop or FRICTION == 0:
		velocity.x = 0
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

	return self


func get_gravity() -> float:
	if is_inverted_gravity:
		return jump_gravity if velocity.y > 0 else fall_gravity
	else:
		return jump_gravity if velocity.y < 0 else fall_gravity


func apply_gravity(delta: float = get_physics_process_delta_time()) -> GodotEssentialsPlatformerMovementComponent:
	if gravity_enabled:
		var gravity_force = get_gravity() * delta

		if is_inverted_gravity:
			gravity_force *= -1
			
		velocity.y += gravity_force

		if MAXIMUM_FALL_VELOCITY > 0:
			velocity.y = max(velocity.y, -MAXIMUM_FALL_VELOCITY) if is_inverted_gravity else min(velocity.y, absf(MAXIMUM_FALL_VELOCITY))

	return self


func invert_gravity() -> GodotEssentialsPlatformerMovementComponent:
	if body and gravity_enabled:
		jump_velocity = -jump_velocity
		

		is_inverted_gravity = jump_velocity > 0
		body.up_direction = Vector2.DOWN if is_inverted_gravity else Vector2.UP
		
		inverted_gravity.emit(is_inverted_gravity)
	
	return self
	
	
func suspend_gravity_for_duration(duration: float):
	if duration > 0:
		gravity_enabled = false
		suspend_gravity_timer.stop()
		suspend_gravity_timer.wait_time = duration
		suspend_gravity_timer.start()


func jump(height: float = jump_height) -> GodotEssentialsPlatformerMovementComponent:
	var height_reduced: int =  max(0, jump_queue.size()) * height_reduced_by_jump
	velocity.y = _calculate_jump_velocity(height - height_reduced)

	jumped.emit(body.global_position)
	jump_queue.append(body.global_position)
	
	return self


func reset_jump_queue() -> GodotEssentialsPlatformerMovementComponent:
	if not jump_queue.is_empty():
		jump_queue.clear()
		jumps_restarted.emit()
	
	return self


func _calculate_jump_velocity(height: int = jump_height, time_to_peak: float = jump_time_to_peak):
	var y_axis = 1.0 if is_inverted_gravity else -1.0
	return ((2.0 * height) / time_to_peak) * y_axis
	
	
func _calculate_jump_gravity(height: int = jump_height, time_to_peak: float = jump_time_to_peak):
	return (2.0 * height) / pow(time_to_peak, 2) 
	
	
func _calculate_fall_gravity(height: int = jump_height, time_to_fall: float = jump_time_to_fall):
	return (2.0 * height) / pow(time_to_fall, 2) 
	

func _create_suspend_gravity_timer(time: float = DEFAULT_GRAVITY_SUSPEND_DURATION):
	if suspend_gravity_timer:
		return
		
	suspend_gravity_timer= Timer.new()
	suspend_gravity_timer.name = "SuspendGravityTimer"
	suspend_gravity_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	suspend_gravity_timer.wait_time = max(0.05, time)
	suspend_gravity_timer.one_shot = true
	suspend_gravity_timer.autostart = false
	
	add_child(suspend_gravity_timer)
	suspend_gravity_timer.timeout.connect(on_suspend_gravity_timeout)

func on_suspend_gravity_timeout():
	gravity_enabled = true

