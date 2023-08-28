class_name GodotEssentialsMotion extends Node2D

signal max_speed_reached
signal stopped
signal knockback_received(direction: Vector2, power: float)
signal temporary_speed_started(previous_speed: float, current_speed: float)
signal temporary_speed_finished
signal teleported(from: Vector2, to: Vector2)


@export_group("Speed")
## The maximum speed this character can reach.
@export var MAX_SPEED: float = 85
## This value makes the time it takes to reach maximum speed smoother.
@export var ACCELERATION: float = 350.0
## The force applied to slow down the character's movement.
@export var FRICTION: float = 750.0

@export_group("Modifiers")
## In seconds, the amount of time a speed modification will endure
@export var DEFAULT_TEMPORARY_SPEED_TIME = 3.0

@export_group("Signals")
## Emits a signal when the body reaches its maximum speed.
@export var max_speed_reached_signal: bool = false
## Emits a signal when this body's velocity reaches zero after movement.
@export var stopped_signal: bool = false
## Emits a signal when a knockback function is called.
@export var knockback_received_signal: bool = false

@onready var body = get_parent() as CharacterBody2D
@onready var original_max_speed: float = MAX_SPEED

var velocity: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.ZERO
var last_faced_direction: Vector2 = Vector2.RIGHT
var temporary_speed_timer: Timer


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	var parent_node = get_parent()
	
	if parent_node == null or not parent_node is CharacterBody2D:
		warnings.append("This component needs a CharacterBody2D parent in order to work properly")
			
	return warnings


func _ready():
	_create_temporary_speed_timer(DEFAULT_TEMPORARY_SPEED_TIME)


func move() -> GodotEssentialsMotion:
	if body:
		body.velocity = velocity
		body.move_and_slide()
		
	return self


func move_and_collide(delta: float = get_physics_process_delta_time()) -> KinematicCollision2D:
	if body:
		body.velocity = velocity
	
		return body.move_and_collide(body.velocity * delta)
	
	return null


func accelerate(direction: Vector2, delta: float =  get_physics_process_delta_time()) -> GodotEssentialsMotion:
	facing_direction = _normalize_vector(direction)
	
	if not direction.is_zero_approx():
		last_faced_direction = facing_direction
		
		if ACCELERATION > 0:
			velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
		else:	
			velocity = direction * MAX_SPEED
		
		
		if max_speed_reached_signal and _velocity_has_reached_max_speed():
			max_speed_reached.emit()

	return self


func decelerate(delta: float = get_physics_process_delta_time(), force_stop: bool = false) -> GodotEssentialsMotion:
	var previous_velocity = velocity
	
	if force_stop or FRICTION == 0:
		velocity = Vector2.ZERO
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	if stopped_signal and not previous_velocity.is_zero_approx() and velocity.is_zero_approx():
		stopped.emit()
	
	return self
	

func accelerate_to_position(position: Vector2) -> GodotEssentialsMotion:
	return accelerate(body.global_position.direction_to(position))


func knockback(direction: Vector2, power: float) -> GodotEssentialsMotion:
	var knockback_direction: Vector2 = _normalize_vector(direction) * max(1, power)

	velocity = knockback_direction

	if knockback_received_signal:
		knockback_received.emit(direction, power)

	return self	

func teleport_to_position(position: Vector2) -> GodotEssentialsMotion:
	var original_position: Vector2  = body.global_position
	body.global_position = position
	
	teleported.emit(original_position, position)
	
	return self


func change_speed_temporary(new_speed: float, time: float = DEFAULT_TEMPORARY_SPEED_TIME) -> GodotEssentialsMotion:
	if temporary_speed_timer:
		temporary_speed_timer.stop()
		temporary_speed_timer.wait_time = max(0.05, absf(time))
		temporary_speed_timer.start()
		
		MAX_SPEED = absf(new_speed)
		
		temporary_speed_started.emit(original_max_speed, new_speed)

	return self


func _normalize_vector(value: Vector2) -> Vector2:
	return value if value.is_normalized() else value.normalized()


func _velocity_has_reached_max_speed() -> bool:
	return velocity.length_squared() >= MAX_SPEED * MAX_SPEED


func _create_temporary_speed_timer(time: float) -> void:
	if temporary_speed_timer:
		return
		
	temporary_speed_timer = Timer.new()
	temporary_speed_timer.name = "TemporarySpeedTimer"
	temporary_speed_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	temporary_speed_timer.wait_time = time
	temporary_speed_timer.one_shot = true
	temporary_speed_timer.autostart = false

	add_child(temporary_speed_timer)
	temporary_speed_timer.timeout.connect(on_temporary_speed_timer_timeout)
	

func on_temporary_speed_timer_timeout():
	MAX_SPEED = original_max_speed
	temporary_speed_finished.emit()

