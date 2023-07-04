extends CharacterBody2D


@onready var health_component: HealthComponent = $HealthComponent
@onready var velocity_component_2d: VelocityComponent2D = $VelocityComponent2D
@onready var animation_tree = $AnimationTree

func _ready():
	animation_tree.active = true
	
func _physics_process(delta):
	var direction: Vector2 = get_input_direction()
	
	velocity_component_2d.accelerate_in_direction(direction).move()
	
	if direction.is_equal_approx(Vector2.ZERO):
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_walking"] = false
	else:
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_walking"] = true
	
	animation_tree["parameters/Idle/blend_position"] = velocity_component_2d.last_faced_direction
	animation_tree["parameters/Walk/blend_position"] = direction


func get_input_direction() -> Vector2:
	return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
