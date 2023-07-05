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
@export var dash_cooldown: float = 1.5

@export_group("Knockback")
@export var knockback_power: int = 300
#################################################3

var can_dash: bool = false
var dash_queue: Array[String] = []

var velocity: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.ZERO
var last_faced_direction: Vector2 = Vector2.DOWN


func _ready():
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
	if can_dash and dash_queue.size() < times_can_dash:
		dash_queue.append("dash")
		
		velocity *= dash_speed_multiplier
		facing_direction = target_direction
		move()
		
		_create_dash_cooldown_timer()
		dashed.emit()
		
	
func enable_dash(cooldown: float = dash_cooldown, times: int = times_can_dash):
	can_dash =  cooldown > 0 and times_can_dash > 0
	times_can_dash = times
	
func on_dash_cooldown_timer_timeout():
	dash_queue.pop_back()
	can_dash = dash_queue.size() < times_can_dash

	for child in get_children():
		if child is Timer and child.is_stopped():
			child.queue_free()
	

func _create_dash_cooldown_timer(time: float = dash_cooldown):
	var dash_cooldown_timer: Timer = Timer.new()
	
	dash_cooldown_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	dash_cooldown_timer.wait_time = max(0.05, time)
	dash_cooldown_timer.one_shot = true
	dash_cooldown_timer.autostart = true
	
	add_child(dash_cooldown_timer)
	dash_cooldown_timer.timeout.connect(on_dash_cooldown_timer_timeout)
