extends CharacterBody2D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var navigation_agent_2d: NavigationAgent2D = $Navigation/NavigationAgent2D
@onready var velocity_component_2d: VelocityComponent2D = $VelocityComponent2D

var initial_position: Vector2 = Vector2.ZERO
var target_node: Node2D = null

func _ready():
	initial_position = self.global_position
	animation_tree.active = true
	

func _physics_process(_delta):
	if navigation_agent_2d.is_navigation_finished():
		return
	
	var direction: Vector2 = to_local(navigation_agent_2d.get_next_path_position()).normalized()

	if direction.is_equal_approx(Vector2.ZERO):
		animation_tree.set("parameters/conditions/idle", true)
		animation_tree.set("parameters/conditions/is_walking", false) 
	else:
		animation_tree.set("parameters/conditions/idle", false)
		animation_tree.set("parameters/conditions/is_walking", true) 
	
	animation_tree.set("parameters/Idle/blend_position", velocity_component_2d.last_faced_direction)
	animation_tree.set("parameters/Walk/blend_position", direction)
	
	velocity_component_2d.accelerate_in_direction(direction).move()


func _on_player_detection_area_body_entered(body: Node2D):
	target_node = body
	animation_tree.set("parameters/conditions/is_jumping", false)
	animation_tree.set("parameters/conditions/is_walking", true) 
		

func _on_player_detection_area_body_exited(_body:Node2D):
	target_node = null
	animation_tree.set("parameters/conditions/is_jumping", true)
	animation_tree.set("parameters/conditions/is_walking", false) 

func recalculate_path():
	if target_node:
		navigation_agent_2d.target_position = target_node.global_position
	else:
		navigation_agent_2d.target_position = initial_position
		
func _on_chase_timer_timeout():
	recalculate_path()
	
