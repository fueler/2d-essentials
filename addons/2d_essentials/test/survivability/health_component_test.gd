# GdUnit generated TestSuite
class_name HealthComponentextendsNode2dTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://addons/2d_essentials/survivability/health_component.gd'
var preloaded_component_script

func before():
	preloaded_component_script = preload(__source)


func test_instance_of_two_different_components_have_different_parameters() -> void:
	var first_health_component_test_instance = auto_free(preloaded_component_script.new())
	var second_health_component_test_instance = auto_free(preloaded_component_script.new())
	
	first_health_component_test_instance.max_health = 1300
	first_health_component_test_instance.current_health = 1000
	first_health_component_test_instance.health_regen_per_second = 5
	first_health_component_test_instance.is_invulnerable = false
	
	second_health_component_test_instance.max_health = 500
	second_health_component_test_instance.current_health = 500
	second_health_component_test_instance.health_regen_per_second = 1
	second_health_component_test_instance.is_invulnerable = true
	
	assert_int(first_health_component_test_instance.max_health).is_not_equal(second_health_component_test_instance.max_health)
	assert_int(first_health_component_test_instance.current_health).is_not_equal(second_health_component_test_instance.current_health)
	assert_int(first_health_component_test_instance.health_regen_per_second).is_not_equal(second_health_component_test_instance.current_health)
	assert_bool(first_health_component_test_instance.is_invulnerable).is_not_equal(second_health_component_test_instance.is_invulnerable)
	
func test_damage_removes_life_correctly() -> void:
	var health_component_test_instance = auto_free(preloaded_component_script.new())
	
	health_component_test_instance.max_health = 100
	health_component_test_instance.current_health = 100
	
	assert_int(health_component_test_instance.current_health).is_equal(health_component_test_instance.max_health)
	
	health_component_test_instance.damage(25)
	
	assert_int(health_component_test_instance.max_health).is_equal(100)
	assert_int(health_component_test_instance.current_health).is_equal(75)
	
	health_component_test_instance.damage(70)
	assert_int(health_component_test_instance.max_health).is_equal(100)
	assert_int(health_component_test_instance.current_health).is_equal(5)
	
	## Negative values does not mess up the process
	health_component_test_instance.damage(-4)
	assert_int(health_component_test_instance.max_health).is_equal(100)
	assert_int(health_component_test_instance.current_health).is_equal(1)
	
	
func test_damage_never_let_current_health_stay_below_zero() -> void:
	var health_component_test_instance = auto_free(preloaded_component_script.new())

	health_component_test_instance.damage(99999999999999)
	
	assert_int(health_component_test_instance.current_health).is_equal(0)

func test_health_add_lifes_as_expected():
	var health_component_test_instance = auto_free(preloaded_component_script.new())
	
	health_component_test_instance.max_health = 125
	health_component_test_instance.current_health = 30
	
	health_component_test_instance.health(25)
	
	assert_int(health_component_test_instance.current_health).is_equal(55)
	
func test_health_never_add_life_above_the_max_health():
	var health_component_test_instance = auto_free(preloaded_component_script.new())
	
	health_component_test_instance.max_health = 125
	health_component_test_instance.current_health = 30
	
	health_component_test_instance.health(300)
	
	assert_int(health_component_test_instance.current_health).is_equal(health_component_test_instance.max_health)
	
func test_health_percent_correspond_to_the_max_and_current_health():
	# 1.0 corresponds to 100% as the godot editor works with decimals
	var health_component_test_instance = auto_free(preloaded_component_script.new())
	
	health_component_test_instance.max_health = 100
	health_component_test_instance.current_health = 100
	
	assert_float(health_component_test_instance.get_health_percent()).is_equal(1.0)
	
	health_component_test_instance.current_health = 45
	assert_float(health_component_test_instance.get_health_percent()).is_equal(0.45)
	
	health_component_test_instance.current_health = 0
	assert_float(health_component_test_instance.get_health_percent()).is_equal(0.0)


func test_damage_is_zero_when_invulnerability_is_active():
	var health_component_test_instance = auto_free(preloaded_component_script.new())

	add_child(health_component_test_instance)
	health_component_test_instance.current_health = 125
	health_component_test_instance.enable_invulnerability(true, 2.0)
	health_component_test_instance.damage(999999999999999999)
	
	assert_int(health_component_test_instance.current_health).is_equal(125)
	
	
func test_signal_exists_on_health_component():
	var health_component_test_instance = auto_free(preloaded_component_script.new())
	
	assert_signal(health_component_test_instance)\
		.is_signal_exists("health_changed")\
		.is_signal_exists("invulnerability_changed")\
		.is_signal_exists("died")
		
		
func test_signal_invulnerability_changed_emitted_after_enable():
	var health_component_test_instance = auto_free(preloaded_component_script.new())

	add_child(health_component_test_instance)
	var timer: Timer = Timer.new()
	
	timer.name = "InvulnerabilityTimer"
	
	health_component_test_instance.add_child(timer)
	health_component_test_instance.enable_invulnerability(true, 2.0)
	
	await assert_signal(health_component_test_instance).is_emitted("invulnerability_changed", [true])


func test_signal_invulnerability_changed_emitted_after_timeout():
	var health_component_test_instance = auto_free(preloaded_component_script.new())

	add_child(health_component_test_instance)
	var timer: Timer = Timer.new()
	
	timer.name = "InvulnerabilityTimer"
	
	health_component_test_instance.add_child(timer)
	
	health_component_test_instance.enable_invulnerability(true, 2.0)
	
	await assert_signal(health_component_test_instance).wait_until(2100).is_emitted("invulnerability_changed", [false])
	

func test_signal_died_after_current_health_is_zero():
	var health_component_test_instance = auto_free(preloaded_component_script.new())
	health_component_test_instance.max_health = 100
	health_component_test_instance.current_health = 100
	
	add_child(health_component_test_instance)

	health_component_test_instance.damage(101)
	
	await assert_signal(health_component_test_instance).is_emitted("died")
	
func test_signal_after_damage_is_emitted() -> void:
	var health_component_test_instance = auto_free(preloaded_component_script.new())
	add_child(health_component_test_instance)
	
	health_component_test_instance.damage(10)
	
	await assert_signal(health_component_test_instance).is_emitted("health_changed", [10,  health_component_test_instance.TYPES.DAMAGE])
