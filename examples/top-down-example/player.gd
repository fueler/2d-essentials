extends CharacterBody2D


@onready var health_component: HealthComponent = $HealthComponent
@onready var velocity_component_2d: VelocityComponent2D = $VelocityComponent2D
@onready var animation_tree: AnimationTree = $AnimationTree

func _ready():
	animation_tree.active = true
	
	health_component.died.connect(on_player_died)
	
func _physics_process(delta):
	var direction: Vector2 = get_input_direction()
	
	if direction.is_equal_approx(Vector2.ZERO):
		animation_tree.set("parameters/conditions/idle", true)
		animation_tree.set("parameters/conditions/is_walking", false) 
	else:
		animation_tree.set("parameters/conditions/idle", false) 
		animation_tree.set("parameters/conditions/is_walking", true)

	animation_tree.set("parameters/Idle/blend_position", velocity_component_2d.last_faced_direction)
	animation_tree.set("parameters/Walk/blend_position", direction)
	animation_tree.set("parameters/SlashAttack/blend_position", velocity_component_2d.last_faced_direction)
	
	animation_tree.set("parameters/conditions/is_attacking", Input.is_action_just_pressed("attack"))

	
	velocity_component_2d.\
		accelerate_in_direction(direction)\
		.move()
	
	if Input.is_action_just_pressed("dash"):
		velocity_component_2d.dash()


func get_input_direction() -> Vector2:
	return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()

func on_player_died():
	animation_tree.set("parameters/conditions/idle", false)
	animation_tree.set("parameters/conditions/is_walking", false) 
	animation_tree.set("parameters/conditions/is_attacking", false) 
	
	animation_tree.set("parameters/Die/blend_position", velocity_component_2d.last_faced_direction)
	animation_tree["parameters/playback"].travel("Die")


func _on_slash_attack_area_entered(area: Area2D):
	var target = area.get_parent()
	
	target.health_component.damage(10)
	target.velocity_component_2d.knockback(velocity_component_2d.velocity)
