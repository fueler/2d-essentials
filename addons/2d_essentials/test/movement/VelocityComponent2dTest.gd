# GdUnit generated TestSuite
class_name VelocityComponent2DextendsNode2dTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://addons/2d_essentials/movement/velocity_component_2d.gd'

var preloaded_component_script

func before():
	preloaded_component_script = preload(__source)

func test_move_without_body() -> void:
	var velocity_component_instance = auto_free(preloaded_component_script.new())
	
	# should return self without raising exceptions
	var velocity_component = velocity_component_instance.move()
	
	assert_that(velocity_component).is_class("VelocityComponent2D")
	
func test_move() -> void:
	# Move by itself should not alter the body because velocity is not updated here
	var velocity_component_instance = auto_free(preloaded_component_script.new())
	var body = auto_free(CharacterBody2D.new())
	
	body.add_child(velocity_component_instance)
	add_child(body)
	
	assert_vector2(Vector2.ZERO).is_equal(body.velocity)
	velocity_component_instance.move()
	assert_vector2(Vector2.ZERO).is_equal(body.velocity)
	
func test_accelerate_in_direction() -> void:
	var velocity_component_instance = auto_free(preloaded_component_script.new())
	var body = auto_free(CharacterBody2D.new())
	
	body.add_child(velocity_component_instance)
	add_child(body)
	
	velocity_component_instance.max_speed = 130
	velocity_component_instance.acceleration_smoothing = 15.0
	
	assert_vector2(Vector2.ZERO).is_equal(body.velocity)
	
	velocity_component_instance.accelerate_in_direction(Vector2.RIGHT).move()
	assert_vector2(body.velocity).is_equal_approx(Vector2(28.8,0), Vector2(0.1,0))
	
	velocity_component_instance.accelerate_in_direction(Vector2.LEFT).move()
	assert_vector2(body.velocity).is_equal_approx(Vector2(-6.360779, 0), Vector2(0.01, 0))

	velocity_component_instance.accelerate_in_direction(Vector2.UP).move()
	assert_vector2(body.velocity).is_equal_approx(Vector2(-4.95379, -28.7559), Vector2(0.01, 0.01))

	velocity_component_instance.accelerate_in_direction(Vector2.DOWN).move()
	assert_vector2(body.velocity).is_equal_approx(Vector2(-3.858, 6.3607), Vector2(0.01, 0.01))
	

func test_dash_dont_move_the_character_when_is_stopped():
	var velocity_component_instance = auto_free(preloaded_component_script.new())
	var body = auto_free(CharacterBody2D.new())

	body.add_child(velocity_component_instance)
	add_child(body)
	
	body.velocity = Vector2.ZERO
	
	velocity_component_instance.dash_speed_multiplier = 2
	velocity_component_instance.times_can_dash = 3
	velocity_component_instance.dash_cooldown = 1
	
	velocity_component_instance.dash()
	
	assert_vector2(body.velocity).is_equal(Vector2.ZERO)
	assert_signal(velocity_component_instance).is_not_emitted("dashed")
	
func test_dash_multiply_the_speed_and_create_the_cooldown_timers():
	var velocity_component_instance = auto_free(preloaded_component_script.new())

	var body = auto_free(CharacterBody2D.new())
	
	velocity_component_instance.dash_speed_multiplier = 2
	velocity_component_instance.times_can_dash = 3
	velocity_component_instance.dash_cooldown = 1
	velocity_component_instance.velocity = Vector2(10, 10)
	#var spy_velocity_instance = spy(velocity_component_instance)
	
	body.velocity = velocity_component_instance.velocity
	body.add_child(velocity_component_instance)
	add_child(body)
		
	velocity_component_instance.dash()
	
	#verify(spy_velocity_instance, 1)._create_dash_cooldown_timer()
	
	assert_vector2(body.velocity).is_equal(Vector2(20, 20))
	assert_signal(velocity_component_instance).is_emitted("dashed")
	
