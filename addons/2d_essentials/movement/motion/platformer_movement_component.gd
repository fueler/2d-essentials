class_name GodotEssentialsPlatformerMovementComponent extends GodotEssentialsMotion

signal gravity_changed(enabled: bool)
signal inverted_gravity(inverted: bool)
signal jumped(position: Vector2)
signal wall_jumped(normal: Vector2, position: Vector2)
signal allowed_jumps_reached(jump_positions: Array[Vector2])
signal jumps_restarted
signal coyote_time_started
signal coyote_time_finished


@export_group("Gravity")
## The maximum vertical velocity while falling to control fall speed
@export var MAXIMUM_FALL_VELOCITY: float = 200.
## The default duration in seconds when the gravity is suspended
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

@export_group("Wall Jump")
## Enable the wall jump action
@export var wall_jump_enabled : bool = false
## Defines whether the wall jump is counted as a jump in the overall count.
@export var wall_jump_count_as_jump: bool = false
## The maximum angle of deviation that a wall can have to allow the jump to be executed.
@export var maximum_permissible_wall_angle : float = 0.0

@export_group("Wall Slide")
# Enable the sliding when the character is on a wall
@export var wall_slide_enabled: bool = false
## The gravity applied to start sliding on the wall until reach the floor
@export var wall_slide_gravity: float = 50.0

@export_group("Wall Climb")
## Enable the wall climb action
@export var wall_climb_enabled: bool = false
## The speed when climb upwards
@export var wall_climb_speed_up: float = 50.0
## The speed when climb downwards
@export var wall_climb_speed_down: float = 55.0
## The force applied when the time it can climb reachs the timeout
@export var wall_climb_fatigue_knockback: float = 100.0
## Window time range in which where you can be climbing without getting tired of it
@export var time_it_can_climb: float = 3.0
## Time that the climb action is disabled when the fatigue timeout is triggered.
@export var time_disabled_when_timeout: float = 0.7


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
var coyote_timer: Timer
var jump_queue: Array[Vector2] = []

func _ready():
	super._ready()
	_create_suspend_gravity_timer()
	
	wall_jumped.connect(on_wall_jumped)


func move() -> void:
	var was_on_floor: bool = body.is_on_floor()
	super.move()
	
	var just_left_edge = was_on_floor and not body.is_on_floor()
	
	if just_left_edge and coyote_timer.is_stopped():
		coyote_time_started.emit()
		

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
			if is_inverted_gravity:
				velocity.y = max(velocity.y, -MAXIMUM_FALL_VELOCITY)
			else:
				velocity.y = min(velocity.y, absf(MAXIMUM_FALL_VELOCITY))	
			
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


func can_jump() -> bool:
	var coyote_jump_active: bool = coyote_jump_enabled and coyote_timer.time_left > 0.0
	var available_jumps: bool = jump_queue.size() < allowed_jumps
	var is_withing_threshold: bool = jump_velocity_threshold == 0
	
	if jump_velocity_threshold > 0:
		if is_inverted_gravity:
			is_withing_threshold = velocity.y > 0 or (velocity.y < -jump_velocity_threshold)
		else:	
			is_withing_threshold = velocity.y < 0 or (velocity.y < jump_velocity_threshold)

	return available_jumps and (coyote_jump_active or is_withing_threshold)


func can_wall_jump() -> bool:
	var is_on_wall: bool =  wall_jump_enabled and body.is_on_wall()
	var available_jumps: bool = not wall_jump_count_as_jump or (wall_jump_count_as_jump and jump_queue.size() < allowed_jumps)
	
	return is_on_wall and available_jumps
		

func jump(height: float = jump_height, bypass: bool = false) -> GodotEssentialsPlatformerMovementComponent:
	if bypass or can_jump():
		var height_reduced: int =  max(0, jump_queue.size()) * height_reduced_by_jump
		velocity.y = _calculate_jump_velocity(height - height_reduced)

		add_position_to_jump_queue(body.global_position)
		jumped.emit(body.global_position)
		
	return self


func wall_jump(direction: Vector2, height: float = jump_height) -> GodotEssentialsPlatformerMovementComponent:
	var wall_normal: Vector2 = body.get_wall_normal()
	var left_angle: float = absf(wall_normal.angle_to(Vector2.LEFT))
	var right_angle: float = absf(wall_normal.angle_to(Vector2.RIGHT))
	
	jump(height, true)
	velocity.x = wall_normal.x * velocity.y
	
	if wall_jump_count_as_jump:
		add_position_to_jump_queue(body.global_position)

	wall_jumped.emit(wall_normal, body.global_position)
	
	return self
	

func can_wall_slide() -> bool:
	return wall_slide_enabled and body.is_on_wall()
	
	
func wall_slide(delta: float =  get_physics_process_delta_time()) -> GodotEssentialsPlatformerMovementComponent:
	if can_wall_slide():
		velocity.y += wall_slide_gravity * delta
		
		if is_inverted_gravity:
			velocity.y = max(velocity.y - wall_slide_gravity * delta, -wall_slide_gravity)
		else:
			velocity.y = min(velocity.y + wall_slide_gravity * delta, wall_slide_gravity)
			
	return self
	

func can_wall_climb() -> bool:
	return wall_climb_enabled and body.is_on_wall()
	
	
func wall_climb(direction: Vector2) -> GodotEssentialsPlatformerMovementComponent:
	if can_wall_climb():
		direction = _normalize_vector(direction)
		
		if direction.is_zero_approx():
			decelerate(true)
		else:
			var wall_climb_speed: float = 0.0
			
			match(direction):
				Vector2.UP:
					wall_climb_speed = wall_climb_speed_up
				Vector2.DOWN:
					wall_climb_speed = wall_climb_speed_down
			
			velocity.y = direction.y * wall_climb_speed
			
			if is_inverted_gravity:
				velocity.y *= -1
				
	return self
	
	
func reset_jump_queue() -> GodotEssentialsPlatformerMovementComponent:
	if not jump_queue.is_empty():
		jump_queue.clear()
		jumps_restarted.emit()
	
	return self


func add_position_to_jump_queue(position: Vector2):
	jump_queue.append(position)
	
	if jump_queue.size() == allowed_jumps:
		allowed_jumps_reached.emit(jump_queue)
	

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


func _create_coyote_timer():
	if coyote_timer:
		return
	
	coyote_timer = Timer.new()
	coyote_timer.name = "CoyoteTimer"
	coyote_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	coyote_timer.wait_time = coyote_jump_time_window
	coyote_timer.one_shot = true
	coyote_timer.autostart = false

	add_child(coyote_timer)
	coyote_timer.timeout.connect(on_coyote_timer_timeout)
	coyote_time_started.connect(on_coyote_time_started)


func on_suspend_gravity_timeout():
	gravity_enabled = true


func on_coyote_time_started():
	gravity_enabled = false
	coyote_timer.start()


func on_coyote_timer_timeout():
	gravity_enabled = true
	coyote_time_finished.emit()


func on_wall_jumped(normal: Vector2, position: Vector2):
	if not normal.is_zero_approx():
		facing_direction = normal
		last_faced_direction = normal
	
