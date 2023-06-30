@tool
extends EditorPlugin

const HELPERS_AUTOLOAD = "Helpers"

func _enter_tree():
	add_autoload_singleton(HELPERS_AUTOLOAD, "res://addons/2d_essentials/autoload/helpers.tscn")
	add_custom_type("HealthComponent", "Node2D", preload("res://addons/2d_essentials/health/health_component.tscn").get_script(), preload("res://addons/2d_essentials/Battery.png"))


func _exit_tree():
	remove_custom_type("HealthComponent")
	remove_autoload_singleton(HELPERS_AUTOLOAD)
