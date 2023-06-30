@tool
extends Node2D

class_name HealthComponent

signal health_changed(amount: int, type: TYPES)
signal invulnerability_changed(active: bool)
signal died

@onready var invulnerability_timer: Timer = $InvulnerabilityTimer
@onready var health_regen_timer: Timer = $HealthRegenTimer

@export var max_health: int = 100
@export var current_health: int = max_health
@export var health_regen_per_second: int = 0
@export var is_invulnerable:bool = false

enum TYPES {
	HEALTH,
	DAMAGE,
	REGEN
}

func _ready():
	health_changed.connect(on_health_changed)
	
	if health_regen_timer:
		health_regen_timer.timeout.connect(on_health_regen_timer_timeout)
		enable_health_regen()
		
	if invulnerability_timer:
		invulnerability_timer.timeout.connect(on_invulnerability_timer_timeout)


func damage(amount: int):
	if is_invulnerable: amount = 0
	
	current_health = max(0, current_health - amount)
	
	health_changed.emit(amount, TYPES.DAMAGE)


func health(amount: int, type: TYPES = TYPES.HEALTH):
	current_health = min(max_health, current_health + amount)
	health_changed.emit(amount, type)
	
	
func check_is_death():
	if current_health == 0:
		died.emit()
		owner.queue_free()
		

func enable_invulnerabiliy(enable: bool, time: float = 0.05):
	if enable:
		is_invulnerable = true
		
		if invulnerability_timer: 
			invulnerability_timer.wait_time = max(0.05, time)
			invulnerability_timer.one_shot = true
			invulnerability_timer.start()
	else:
		is_invulnerable = false
		
		if invulnerability_timer:
			invulnerability_timer.stop()

	invulnerability_changed.emit(enable)


func enable_health_regen(amount_per_second: int = health_regen_per_second):
	health_regen_per_second = amount_per_second
	
	if health_regen_timer and health_regen_per_second > 0 and current_health != max_health:
		health_regen_timer.stop()
		
		health_regen_timer.one_shot = false
		health_regen_timer.wait_time = 1.0
		health_regen_timer.start()

	
func get_health_percent() -> float:
	return max(0, current_health / max_health)
	
	
func on_health_changed(amount: int, type: TYPES):
	if type == TYPES.DAMAGE:
		Callable(check_is_death).call_deferred()


func on_health_regen_timer_timeout():
	health(health_regen_per_second, TYPES.REGEN)
	
	if current_health == max_health:
		health_regen_timer.stop()
	
		
func on_invulnerability_timer_timeout():
	enable_invulnerabiliy(false)
	
