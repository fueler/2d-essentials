@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("HealthComponent", "Node2D", preload("res://addons/health/health_component.gd"), preload("res://icon.svg"))


func _exit_tree():
	remove_custom_type("HealthComponent")
