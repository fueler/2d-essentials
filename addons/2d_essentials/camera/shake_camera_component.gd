extends Node2D
class_name ShakeCameraComponent2D

@onready var camera2d: Camera2D = get_parent()

@export var default_shake_strength = 15.0
@export var shake_duration: float = 1.5

var random_number_generator = RandomNumberGenerator.new()
var shake_duration_timer: Timer
var shake_strength: float = 0.0

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	var parent_node = get_parent()
	
	if parent_node == null or not parent_node is Camera2D:
		warnings.append("This component needs to be a child of Camera2D")
			
	return warnings


func _ready():
	_create_shake_duration_timer()
	
	
func _process(delta):
	shake_camera(shake_strength, delta)


func shake_camera(fade: float = 5.0, delta: float = get_process_delta_time()):
	if shake_strength > 0:
		if shake_duration_timer.is_stopped():
			shake_duration_timer.start()
			
		shake_strength = lerpf(shake_strength, 0, fade * delta)
		camera2d.offset = Vector2(random_number_generator.randf_range(-shake_strength, shake_strength), random_number_generator.randf_range(-shake_strength,shake_strength))


func shake(strength: float = default_shake_strength, time: float = shake_duration):
	shake_strength = strength
	
	if shake_duration_timer:
		shake_duration_timer.stop()
		shake_duration_timer.wait_time = max(0.05, time)

func _create_shake_duration_timer(time:float = shake_duration):
	shake_duration_timer = Timer.new()

	shake_duration_timer.process_callback = Timer.TIMER_PROCESS_IDLE
	shake_duration_timer.wait_time = max(0.05, time)
	shake_duration_timer.one_shot = true
	shake_duration_timer.autostart = false

	add_child(shake_duration_timer)
	shake_duration_timer.timeout.connect(on_shake_duration_timer_timeout)
	
	
func on_shake_duration_timer_timeout():
	shake_strength = 0.0
