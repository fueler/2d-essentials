class_name GodotEssentialsDashMovementComponent extends GodotEssentialsMotion

signal dashed(position: Vector2)

@export_group("Dash")
## The speed multiplier would be applied to the player velocity on runtime
@export var DASH_SPEED_MULTIPLIER: float = 1.5
## The times this character can dash until the cooldown is activated
@export_range(1, 10, 1, "or_greater") var times_can_dash: int = 1
## The time it takes for the dash ability to become available again.
@export var dash_cooldown: float = 1.5
## The time this dash will be active
@export var dash_duration: float = 0.3

var dash_duration_timer: Timer
var dash_queue: Array[Vector2] = []
var is_dashing: bool = false


func _ready():
	super._ready()
	_create_dash_duration_timer()
	

func has_available_dashes() -> bool:
	return dash_queue.size() < times_can_dash


func can_dash(direction: Vector2 = Vector2.ZERO) -> bool:
	return not direction.is_zero_approx() and has_available_dashes()


func dash(target_direction: Vector2 = facing_direction, speed_multiplier: float = DASH_SPEED_MULTIPLIER) -> GodotEssentialsDashMovementComponent:
	if can_dash(target_direction):
		facing_direction = _normalize_vector(target_direction)
		last_faced_direction = facing_direction
		is_dashing = true
		velocity = target_direction * (MAX_SPEED * max(1, absf(speed_multiplier)))

		dash_queue.append(body.global_position)
		dash_duration_timer.start()

		_create_dash_cooldown_timer()
		
		dashed.emit(body.global_position)
	
	return self
	
func _create_dash_duration_timer(time: float = dash_duration):
	if dash_duration_timer:
		return
		
	dash_duration_timer = Timer.new()
	dash_duration_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	dash_duration_timer.wait_time = time
	dash_duration_timer.one_shot = true
	dash_duration_timer.autostart = false
	
	add_child(dash_duration_timer)
	dash_duration_timer.timeout.connect(on_dash_duration_timer_timeout)


func _create_dash_cooldown_timer(time: float = dash_cooldown):
	var dash_cooldown_timer: Timer = Timer.new()

	dash_cooldown_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	dash_cooldown_timer.wait_time = max(0.05, time)
	dash_cooldown_timer.one_shot = true
	dash_cooldown_timer.autostart = true
	
	add_child(dash_cooldown_timer)
	dash_cooldown_timer.timeout.connect(on_dash_cooldown_timer_timeout.bind(dash_cooldown_timer))


func on_dash_cooldown_timer_timeout(timer: Timer):
	dash_queue.pop_back()
	timer.queue_free()
	
	
func on_dash_duration_timer_timeout():
	is_dashing = false
	
