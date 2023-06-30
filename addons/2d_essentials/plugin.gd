@tool
extends EditorPlugin

const GLOBALS_AUTOLOAD = "Globals2D"

func _enter_tree():
	add_autoload_singleton(GLOBALS_AUTOLOAD, "res://addons/2d_essentials/autoload/globals.gd")
	add_custom_type("HealthComponent", "Node2D", preload("res://addons/2d_essentials/health/health_component.gd"), preload("res://icon.svg"))


func _exit_tree():
	remove_custom_type("HealthComponent")
	remove_autoload_singleton(GLOBALS_AUTOLOAD)
