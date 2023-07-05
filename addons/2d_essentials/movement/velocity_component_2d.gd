@tool

class_name VelocityComponent2D extends Node2D

############ SIGNALS ############
signal dashed
signal knockback_received
########## EDITABLE PARAMETERS ##########
@export_group("Speed")
## The max speed this character can reach
@export var max_speed: int = 125
## This value makes smoother the time it takes to reach maximum speed  
@export var acceleration_smoothing: float = 15


@export_group("Dash")
## The speed multiplier would be applied to the player velocity on runtime
@export var dash_speed_multiplier: int = 2
## The times this character can dash until the cooldown is activated
@export_range(1, 5, 1, "or_greater") var times_can_dash: int = 1
## The time it takes for the dash ability to become available again.
@export var dash_cooldown: float = 0.0

@export_group("Knockback")
@export var knockback_power: int = 300
#################################################3

var dash_cooldown_timer: Timer
var can_dash: bool = false
var dash_queue: Array[int] = []

var velocity: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.ZERO
var last_faced_direction: Vector2 = Vector2.DOWN


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	var has_dash_cooldown_timer = false
	
	for child in get_children():
		if child is Timer and child.name == "DashCooldownTimer":
			has_dash_cooldown_timer = true
			
	if !has_dash_cooldown_timer and dash_cooldown > 0:
		warnings.append("A Timer with the name 'DashCooldownTimer' is needed when the parameter 'dash_cooldown' is greater than zero")
			
	return warnings
	
	
func _ready():
	dash_cooldown_timer = get_node_or_null("DashCooldownTimer")
	
	enable_dash(dash_cooldown)


func move(body: CharacterBody2D = get_parent()):
	if body:
		body.velocity = velocity
		body.move_and_slide()
	
	return self
	
func accelerate_in_direction(direction: Vector2):
	if !direction.is_equal_approx(Vector2.ZERO):
		last_faced_direction = direction
		
	facing_direction = direction

	var smoothing_factor: float = 1 - exp(-acceleration_smoothing * get_physics_process_delta_time())
	
	velocity = velocity.lerp(facing_direction * max_speed, smoothing_factor)
	
	return self

func accelerate_to_target(target: Node2D):
	var target_direction: Vector2 = (target.global_position - global_position).normalized()
	
	return accelerate_in_direction(target_direction)
	
func decelerate():
	accelerate_in_direction(Vector2.ZERO)
	
	return self

func knockback(from: Vector2, power: int = knockback_power):
	var knockback_direction: Vector2 = (from - velocity).normalized() * power
	velocity = knockback_direction
	
	move()
	
	knockback_received.emit()
	
	
func dash(target_direction: Vector2 = facing_direction):
	if can_dash and dash_cooldown_timer and dash_cooldown_timer.is_stopped():
		if dash_queue.size() <= times_can_dash:
			dash_queue.append(1)
			
			velocity *= dash_speed_multiplier
			facing_direction = target_direction
			move()
			
			dashed.emit()
		else:
			can_dash = false
			dash_cooldown_timer.start()
		
	
func enable_dash(cooldown: float = dash_cooldown, times: int = times_can_dash):
	if cooldown > 0 and times_can_dash > 0 and dash_cooldown_timer:
		
		can_dash = true
		times_can_dash = times
		
		dash_cooldown_timer.one_shot = true
		dash_cooldown_timer.wait_time = cooldown
		dash_cooldown_timer.timeout.connect(on_dash_cooldown_timer_timeout)
	else:
		can_dash = false
		
		if dash_cooldown_timer:
			dash_cooldown_timer.stop()
	
func on_dash_cooldown_timer_timeout():
	can_dash = true
	dash_queue = []
