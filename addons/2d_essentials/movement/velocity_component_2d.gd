class_name VelocityComponent2D extends Node2D

############ SIGNALS ############
signal dashed
signal jumped
signal wall_jumped(normal: Vector2)
signal wall_slide_started
signal wall_slide_finished
signal wall_climb_started
signal wall_climb_finished
signal knockback_received(direction: Vector2)
signal gravity_changed(enabled: bool)
signal inverted_gravity(inverted: bool)

########## EDITABLE PARAMETERS ##########
@export_group("Speed")
## The max speed this character can reach
@export var max_speed: float = 100.0
## This value makes smoother the time it takes to reach maximum speed  
@export var acceleration: float = 0.0
## The force applied to slow down the character's movement
@export var friction: float =  0.0
## The maximum vertical velocity while falling to control fall speed
@export var maximum_fall_velocity: float = 300.0

@export_group("Dash")
## The speed multiplier would be applied to the player velocity on runtime
@export var dash_speed_multiplier: float = 1.5
## The times this character can dash until the cooldown is activated
@export_range(1, 5, 1, "or_greater") var times_can_dash: int = 1
## The time it takes for the dash ability to become available again.
@export var dash_cooldown: float = 1.5
## The time the gravity is disabled when a dash starts
@export var dash_gravity_time_disabled:float = 0.2
## Adjusts the rate of horizontal speed reduction after dashing in the air
@export_range(0.0 ,1.0, 0.001) var air_friction_factor: float = 0.995

@export_group("Jump")
## The maximum height the character can reach
@export var jump_height: float = 85:
	set(value):
		jump_height = value
		jump_velocity = calculate_jump_velocity(jump_height, jump_time_to_peak)
		jump_gravity = calculate_jump_gravity(jump_height, jump_time_to_peak )
		fall_gravity = calculate_fall_gravity(jump_height, jump_time_to_fall)
	get:
		return jump_height
		
## Time it takes to reach the maximum jump height
@export var jump_time_to_peak: float = 0.4:
	set(value):
		jump_time_to_peak = value
		jump_velocity = calculate_jump_velocity(jump_height, jump_time_to_peak)
		jump_gravity = calculate_jump_gravity(jump_height, jump_time_to_peak )
	get:
		return jump_time_to_peak
		
## Time it takes to reach the floor after jump
@export var jump_time_to_fall: float = 0.4:
	set(value):
		jump_time_to_fall = value
		fall_gravity = calculate_fall_gravity(jump_height, jump_time_to_fall)
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
@export var coyote_jump_time_window: float = 0.2

@export_group("Wall Jump")
## Enable the wall jump action
@export var wall_jump_enabled : bool = false
## Defines whether the wall jump is counted as a jump in the overall count.
@export var wall_jump_count_as_jump: bool = false
## The maximum angle of deviation that a wall can have to allow the jump to be executed.
@export var maximum_permissible_wall_angle : float = 0.0
## Enable the sliding when the character is on a wall
@export var wall_slide_enabled: bool = false
## The gravity applied to start sliding on the wall until reach the floor
@export var wall_slide_gravity: float = 50.0

@export_group("Wall Climb")
## Enable the wall climb action
@export var wall_climb_enabled: bool = false
## The speed when climb upwards
@export var wall_climb_speed_up: float = 200.0
## The speed when climb downwards
@export var wall_climb_speed_down: float = 250.0
## The force applied when the time it can climb reachs the timeout
@export var wall_climb_fatigue_knockback: float = 100.0
## Window time range in which where you can be climbing without getting tired of it
@export var time_it_can_climb: float = 3.0
## Time that the climb action is disabled when the fatigue timeout is triggered.
@export var time_disabled_when_timeout: float = 0.7

@onready var jump_velocity: float = calculate_jump_velocity()
@onready var jump_gravity: float =  calculate_jump_gravity()
@onready var fall_gravity: float =  calculate_fall_gravity()

@export_group("Knockback")
## The amount of power the character is pushed in the direction of the force source
@export var knockback_power: int = 250
#################################################

@onready var body = get_parent() as Node2D

var gravity_enabled: bool = true 
var is_inverted_gravity: bool = false

var dash_queue: Array[Vector2] = []

var velocity: Vector2 = Vector2.ZERO

var facing_direction: Vector2 = Vector2.ZERO
var last_faced_direction: Vector2 = Vector2.DOWN

var jump_queue: Array[Vector2] = []

var coyote_timer: Timer
var dash_duration_timer: Timer
var wall_climb_timer: Timer

var is_dashing: bool = false

var is_wall_sliding: bool = false:
	set(value):
		if value != is_wall_sliding:
			if value:
				wall_slide_started.emit()
			else:
				wall_slide_finished.emit()
				
		is_wall_sliding = value
		
var is_wall_climbing: bool = false:
	set(value):
		if value != is_wall_climbing:
			if value:
				wall_climb_started.emit()
			else:
				wall_climb_finished.emit()
				
		is_wall_climbing = value

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	var parent_node = get_parent()
	
	if parent_node == null or not parent_node is Node2D:
		warnings.append("This component needs a Node2D parent in order to work properly")
			
	return warnings
	
	
func _ready():
	_create_coyote_timer()
	_create_dash_duration_timer()
	_create_wall_climbing_timer()
	
	jumped.connect(on_jumped)
	wall_jumped.connect(on_jumped)
	wall_climb_started.connect(on_wall_climb_started)
	wall_climb_finished.connect(on_wall_climb_finished)
	wall_jumped.connect(on_wall_jumped)
	
func move():
	if body:
		var was_on_floor: bool = body.is_on_floor()
	
		body.velocity = velocity
		body.move_and_slide()
		
		check_coyote_jump_time_window(was_on_floor)
		reset_jump_queue()
		
	return self
	
func move_and_collide() -> KinematicCollision2D:
	if body:
		var was_on_floor: bool = body.is_on_floor()
	
		body.velocity = velocity
		var collision: KinematicCollision2D = body.move_and_collide(body.velocity * get_physics_process_delta_time())
		
		check_coyote_jump_time_window(was_on_floor)
		reset_jump_queue()
		
		return collision
	
	return null

func accelerate_in_direction(direction: Vector2, only_horizontal: bool = false):
	facing_direction = direction
	
	if not direction.is_zero_approx():
		last_faced_direction = direction

		if only_horizontal or (acceleration == 0 and friction == 0):
			accelerate_horizontally(direction)
		else:
			if acceleration > 0:
				velocity = velocity.move_toward(direction * max_speed, acceleration * get_physics_process_delta_time())
			else:
				velocity = direction * max_speed

	return self

func accelerate_horizontally(direction: Vector2):
	if not direction.is_zero_approx():
		last_faced_direction = direction
		
		if acceleration > 0:
			velocity.x = lerp(velocity.x, direction.x * max_speed, (acceleration / 100) * get_physics_process_delta_time())
		else:
			velocity.x = direction.x * max_speed
		
	return self

func accelerate_to_target(target: Node2D):
	var target_direction: Vector2 = (target.global_position - global_position).normalized()
	
	return accelerate_in_direction(target_direction)

func accelerate_to_position(position: Vector2):
	var target_direction: Vector2 = (position - global_position).normalized()
	
	return accelerate_in_direction(target_direction)


func decelerate(force_stop: bool = false):
	if force_stop or friction == 0:
		velocity.x = 0
	else:
		velocity.x -= sign(velocity.x) * friction * get_physics_process_delta_time()
		if is_inverted_gravity:
			velocity.x *= -1
		velocity.x = clamp(velocity.x, -max_speed, max_speed)
	
	
	return self
	
func knockback(direction: Vector2, power: int = knockback_power):
	var knockback_direction: Vector2 = (direction if direction.is_normalized() else direction.normalized()) * max(1, power)
	
	decelerate(true)
	velocity = knockback_direction

	move()
	
	knockback_received.emit(direction)
	
	return self	
	
func can_dash(direction: Vector2 = Vector2.ZERO) -> bool:
	return not direction.is_zero_approx() and dash_queue.size() < times_can_dash and dash_cooldown > 0 and times_can_dash > 0 and not velocity.is_zero_approx()
	
func dash(target_direction: Vector2 = facing_direction, speed_multiplier: float = dash_speed_multiplier):
	if can_dash(target_direction):
		facing_direction = target_direction if target_direction.is_normalized() else target_direction.normalized()
		gravity_enabled = false
		is_dashing = true
		is_wall_climbing = false
		is_wall_sliding = false
		dash_queue.append(global_position)
		dash_duration_timer.start()
		
		decelerate(true)
		velocity = target_direction * (max_speed * max(1, absf(speed_multiplier)))
		apply_air_friction()
		
		_create_dash_cooldown_timer()
		
		dashed.emit()
	
	return self
	
func cancel_dash():
	if is_dashing:
		dash_duration_timer.stop()
		dash_duration_timer.timeout.emit()


func apply_air_friction(friction_factor: float = air_friction_factor):
	if air_friction_factor > 0 and not body.is_on_floor() and not body.is_on_wall():
		velocity.x *= friction_factor
		velocity.x = sign(velocity.x) * max(0, absf(velocity.x))
		
	return self

func calculate_jump_velocity(height: int = jump_height, time_to_peak: float = jump_time_to_peak):
	var y_axis = 1.0 if is_inverted_gravity else -1.0
	return ((2.0 * height) / time_to_peak) * y_axis
	
	
func calculate_jump_gravity(height: int = jump_height, time_to_peak: float = jump_time_to_peak):
	return (2.0 * height) / pow(time_to_peak, 2) 
	
	
func calculate_fall_gravity(height: int = jump_height, time_to_fall: float = jump_time_to_fall):
	return (2.0 * height) / pow(time_to_fall, 2) 
	
	
func get_gravity() -> float:
	if is_inverted_gravity:
		return jump_gravity if velocity.y > 0.0 else fall_gravity
	else:
		return jump_gravity if velocity.y < 0.0 else fall_gravity


func apply_gravity():
	if gravity_enabled:
		var gravity_force = get_gravity() * get_physics_process_delta_time()

		if is_inverted_gravity:
			velocity.y -= gravity_force
		else:
			velocity.y += gravity_force

		if maximum_fall_velocity > 0:
			velocity.y = max(velocity.y, -maximum_fall_velocity) if is_inverted_gravity else min(velocity.y, absf(maximum_fall_velocity))

	return self
	
func invert_gravity():
	if body and gravity_enabled:
		jump_velocity = -jump_velocity
		
		if wall_slide_enabled:
			wall_slide_gravity = -wall_slide_gravity
			
		is_inverted_gravity = jump_velocity > 0
		body.up_direction = Vector2.DOWN if is_inverted_gravity else Vector2.UP
		
		inverted_gravity.emit(is_inverted_gravity)
	
	return self


func reset_jump_queue():
	if body.is_on_floor() and jump_queue.size() > 0:
		jump_queue.clear()

func can_jump() -> bool:
	if not can_wall_slide() and not can_wall_climb():
		if body.is_on_floor() or (coyote_jump_enabled and coyote_timer.time_left > 0.0):
			return true
		else:
			return (velocity.y < absf(jump_velocity_threshold) or (is_inverted_gravity and velocity.y < -absf(jump_velocity_threshold))) and jump_queue.size() >= 1 and jump_queue.size() < allowed_jumps 

	return false

func is_withing_jumping_threshold() -> bool:
	var is_withing_threshold = jump_velocity_threshold > 0 and velocity.y < jump_velocity_threshold

	if is_inverted_gravity:
		is_withing_threshold = jump_velocity_threshold < 0 and velocity.y > jump_velocity_threshold
		
	return is_withing_threshold


func jump():
	if can_jump():
		apply_jump()
		
	return self
		
		
func apply_jump():
	jump_queue.append(global_position)
	is_wall_sliding = false
	is_wall_climbing = false
	
	if jump_queue.size() > 1 and height_reduced_by_jump > 0:
		var height_reduced: int =  max(0, jump_queue.size() - 1) * height_reduced_by_jump
		velocity.y = calculate_jump_velocity(jump_height - height_reduced)
	else:
		velocity.y = calculate_jump_velocity(jump_height)
		
	jumped.emit()


func can_wall_jump() -> bool:
	return wall_jump_enabled and body.is_on_wall() and not body.is_on_ceiling() and not velocity.y == 0
	

func wall_jump(direction: Vector2):
	if can_wall_jump():
		var wall_normal: Vector2 = body.get_wall_normal()
		var left_angle: float = absf(wall_normal.angle_to(Vector2.LEFT))
		var right_angle: float = absf(wall_normal.angle_to(Vector2.RIGHT))
		
		if is_wall_sliding or is_wall_climbing:
			apply_wall_jump_direction(wall_normal)
		elif wall_normal.is_equal_approx(Vector2.LEFT) or left_angle <= maximum_permissible_wall_angle:
			apply_wall_jump_direction(wall_normal)
		elif wall_normal.is_equal_approx(Vector2.RIGHT) or right_angle <= maximum_permissible_wall_angle:
			apply_wall_jump_direction(wall_normal)
			
	return self
			
			
func apply_wall_jump_direction(wall_normal: Vector2):
	velocity.x = wall_normal.x * max_speed
	velocity.y = jump_velocity
	
	if wall_jump_count_as_jump:
		jump_queue.append(global_position)
	else:
		reset_jump_queue()

	wall_jumped.emit(wall_normal)
	
func can_wall_climb(direction: Vector2 = facing_direction) -> bool:
	return wall_climb_enabled and(direction.is_equal_approx(Vector2.UP) or direction.is_equal_approx(Vector2.DOWN)) and body.is_on_wall() and not body.is_on_ceiling()
	
func wall_climb(direction: Vector2 = Vector2.ZERO):
	is_wall_climbing = can_wall_climb(direction)

	if is_wall_climbing:
		if gravity_enabled:
			wall_climb_started.emit()
				
		var is_climbing_up = direction.is_equal_approx(Vector2.UP)
		var wall_climb_speed_direction = wall_climb_speed_up if is_climbing_up else wall_climb_speed_down			
		var climb_force = wall_climb_speed_direction * get_physics_process_delta_time()
#		
		if is_inverted_gravity:
			if not is_climbing_up:
				climb_force *= -1
		else:
			if is_climbing_up:
				climb_force *= -1
			
		velocity.y += climb_force
		
		if is_inverted_gravity:
			velocity.y = min(velocity.y, wall_climb_speed_direction) if is_climbing_up else max(velocity.y, -wall_climb_speed_direction)
		else:
			velocity.y = max(velocity.y, -wall_climb_speed_direction) if is_climbing_up else min(velocity.y, wall_climb_speed_direction)

	else:
		if not gravity_enabled:
			wall_climb_finished.emit()
		
	return self
			

func can_wall_slide() -> bool:
	return wall_slide_enabled and not is_wall_climbing and body.is_on_wall() and not body.is_on_floor() and not body.is_on_ceiling()


func wall_slide():
	is_wall_sliding = can_wall_slide()
	
	if not is_wall_climbing and is_wall_sliding:
		velocity.y += wall_slide_gravity * get_physics_process_delta_time()
		velocity.y = max(velocity.y, wall_slide_gravity) if is_inverted_gravity else min(velocity.y, wall_slide_gravity)
		
	return self


func check_coyote_jump_time_window(was_on_floor: bool = true):
	if coyote_jump_enabled:
		var just_left_ledge = was_on_floor and not body.is_on_floor() and (velocity.y >= 0 or (is_inverted_gravity and velocity.y <= 0))
		
		if just_left_ledge:
			coyote_timer.start()
	
	
func enable_dash(cooldown: float = dash_cooldown, times: int = times_can_dash):
	dash_cooldown = cooldown
	times_can_dash = times

func _create_dash_cooldown_timer(time: float = dash_cooldown):
	var dash_cooldown_timer: Timer = Timer.new()

	dash_cooldown_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	dash_cooldown_timer.wait_time = max(0.05, time)
	dash_cooldown_timer.one_shot = true
	dash_cooldown_timer.autostart = true
	
	add_child(dash_cooldown_timer)
	dash_cooldown_timer.timeout.connect(on_dash_cooldown_timer_timeout.bind(dash_cooldown_timer))


func _create_dash_duration_timer(time: float = dash_gravity_time_disabled):
	if dash_duration_timer:
		return
		
	dash_duration_timer = Timer.new()
	dash_duration_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	dash_duration_timer.wait_time = time
	dash_duration_timer.one_shot = true
	dash_duration_timer.autostart = false
	
	add_child(dash_duration_timer)
	dash_duration_timer.timeout.connect(on_dash_duration_timer_timeout)


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


func _create_wall_climbing_timer(time: float = time_it_can_climb):
	if wall_climb_timer:
		return
		
	wall_climb_timer = Timer.new()
	wall_climb_timer.name = "WallClimbTimer"
	wall_climb_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	wall_climb_timer.wait_time = time
	wall_climb_timer.one_shot = true
	wall_climb_timer.autostart = false
	
	add_child(wall_climb_timer)
	wall_climb_timer.timeout.connect(on_wall_climb_timer_timeout)


func on_dash_cooldown_timer_timeout(timer: Timer):
	dash_queue.pop_back()
	timer.queue_free()
	

func on_dash_duration_timer_timeout():
	gravity_enabled = true
	is_dashing = false
	

func on_wall_climb_timer_timeout():
	wall_climb_enabled = false
	wall_climb_finished.emit()
	
	if wall_climb_fatigue_knockback > 0:
		knockback(body.get_wall_normal(), wall_climb_fatigue_knockback)
	
	if time_disabled_when_timeout > 0:
		await (get_tree().create_timer(time_disabled_when_timeout)).timeout

	wall_climb_enabled = true
	
	
func on_jumped():
	is_wall_climbing = false
	is_wall_sliding = false


func on_wall_jumped(normal: Vector2):
	if not normal.is_zero_approx():
		facing_direction = normal
		last_faced_direction = normal
		
func on_wall_climb_started():
	gravity_enabled = false
	wall_climb_timer.start()
	
func on_wall_climb_finished():
	gravity_enabled = true
	wall_climb_timer.stop()
