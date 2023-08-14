@tool
extends EditorPlugin

const HELPERS_AUTOLOAD = "Helpers"

func _enter_tree():
	add_autoload_singleton(HELPERS_AUTOLOAD, "res://addons/2d_essentials/autoload/helpers.tscn")
	add_custom_type("HealthComponent", "Node2D", preload("res://addons/2d_essentials/survivability/health_component.gd"), preload("res://addons/2d_essentials/Backpack.png"))
	add_custom_type("VelocityComponent2D", "Node2D", preload("res://addons/2d_essentials/movement/velocity_component_2d.gd"), preload("res://addons/2d_essentials/Car.png"))
	add_custom_type("ShakeCameraComponent2D", "Node2D", preload("res://addons/2d_essentials/camera/shake_camera_component.gd"), preload("res://addons/2d_essentials/MagnifyingGlass.png"))
	add_custom_type("RotatorComponent", "Node2D", preload("res://addons/2d_essentials/movement/rotator_component.gd"), preload("res://addons/2d_essentials/CD.png"))

func _exit_tree():
	remove_custom_type("HealthComponent")
	remove_custom_type("VelocityComponent2D")
	remove_custom_type("ShakeCameraComponent2D")
	remove_custom_type("RotatorComponent")
	remove_autoload_singleton(HELPERS_AUTOLOAD)
