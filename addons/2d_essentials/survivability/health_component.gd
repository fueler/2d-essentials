@tool

class_name HealthComponent extends Node2D

signal health_changed(amount: int, type: TYPES)
signal invulnerability_changed(active: bool)
signal died

var invulnerability_timer: Timer
var health_regen_timer: Timer

@export_group("Health Parameters")
## The maximum health it can reach
@export var max_health: int = 100
## The actual health
@export var current_health: int = max_health
## The amount of health regenerated each second
@export var health_regen_per_second: int = 0
## The invulnerability flag, when is true no damage is received but can be healed
@export var is_invulnerable:bool = false

enum TYPES {
	DAMAGE,
	HEALTH,
	REGEN
}

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	var has_health_regen_timer = false
	var has_invulnerability_timer = false
	
	for child in get_children():
		if child is Timer and child.name == "HealthRegenTimer":
			has_health_regen_timer = true
		
		if child is Timer and child.name == "InvulnerabilityTimer":
			has_invulnerability_timer = true
	
	if !has_health_regen_timer and health_regen_per_second > 0:
		warnings.append("A Timer with the name 'HealthRegenTimer' is needed when the parameter 'health regen per second' is greater than zero")
	
	if !has_invulnerability_timer and is_invulnerable:
		warnings.append("A Timer with the name 'InvulnerabilityTimer' is needed when the parameter 'is_invulnerable' is set to true")
	
	return warnings
	
func _ready():
	current_health = max(max_health, current_health)
	
	health_regen_timer = get_node_or_null("HealthRegenTimer")
	invulnerability_timer = get_node_or_null("InvulnerabilityTimer")
	
	health_changed.connect(on_health_changed)
	
	if health_regen_timer:
		health_regen_timer.timeout.connect(on_health_regen_timer_timeout)
		enable_health_regen(health_regen_per_second)
		
	if invulnerability_timer:
		invulnerability_timer.timeout.connect(on_invulnerability_timer_timeout)


func damage(amount: int):
	if is_invulnerable: amount = 0
	
	amount = abs(amount)
	
	current_health = max(0, current_health - amount)
	
	health_changed.emit(amount, TYPES.DAMAGE)


func health(amount: int, type: TYPES = TYPES.HEALTH):
	amount = abs(amount)
	current_health = min(max_health, current_health + amount)
	
	health_changed.emit(amount, type)
	
	
func check_is_death():
	if current_health == 0:
		died.emit()

func get_health_percent() -> float:
	return float(current_health) / max_health
	

func enable_invulnerability(enable: bool, time: float = 0.05):
	if enable:
		is_invulnerable = true
		
		if invulnerability_timer: 
			invulnerability_timer.wait_time = max(0.05, time)
			invulnerability_timer.one_shot = true
			invulnerability_timer.start()
			
			invulnerability_changed.emit(true)
	else:
		is_invulnerable = false
		
		if invulnerability_timer:
			invulnerability_timer.stop()
		
		invulnerability_changed.emit(false)


func enable_health_regen(amount_per_second: int = health_regen_per_second):
	if health_regen_timer:
		health_regen_per_second = amount_per_second
		
		if current_health == max_health and health_regen_timer.time_left > 0:
			health_regen_timer.stop()
			return
		
		if health_regen_timer and health_regen_timer.is_stopped() and health_regen_per_second > 0:
			health_regen_timer.one_shot = false
			health_regen_timer.wait_time = 1.0
			health_regen_timer.start()
			
	
func on_health_changed(amount: int, type: TYPES):
	if type == TYPES.DAMAGE:
		enable_health_regen()
		Callable(check_is_death).call_deferred()


func on_health_regen_timer_timeout():
	health(health_regen_per_second, TYPES.REGEN)
	
		
func on_invulnerability_timer_timeout():
	enable_invulnerability(false)
	invulnerability_changed.emit(false)
	
