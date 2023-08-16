@tool
extends EditorPlugin

const HELPERS_AUTOLOAD = "Helpers"
var update_dialog_scene: Node

func _enter_tree():
	add_autoload_singleton(HELPERS_AUTOLOAD, "res://addons/2d_essentials/autoload/helpers.tscn")
	add_custom_type("HealthComponent", "Node2D", preload("res://addons/2d_essentials/survivability/health_component.gd"), preload("res://addons/2d_essentials/Backpack.png"))
	add_custom_type("VelocityComponent2D", "Node2D", preload("res://addons/2d_essentials/movement/velocity_component_2d.gd"), preload("res://addons/2d_essentials/Car.png"))
	add_custom_type("ShakeCameraComponent2D", "Node2D", preload("res://addons/2d_essentials/camera/shake_camera_component.gd"), preload("res://addons/2d_essentials/MagnifyingGlass.png"))
	add_custom_type("RotatorComponent", "Node2D", preload("res://addons/2d_essentials/movement/rotator_component.gd"), preload("res://addons/2d_essentials/CD.png"))
	
	update_dialog_scene = load("res://addons/2d_essentials/update/update_plugin_button.tscn").instantiate()
	Engine.get_main_loop().root.call_deferred("add_child", update_dialog_scene)

func _exit_tree():
	remove_autoload_singleton(HELPERS_AUTOLOAD)
	remove_custom_type("HealthComponent")
	remove_custom_type("VelocityComponent2D")
	remove_custom_type("ShakeCameraComponent2D")
	remove_custom_type("RotatorComponent")
	
	Engine.get_main_loop().root.call_deferred("remove_child", update_dialog_scene)
