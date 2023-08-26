class_name GodotEssentialsState extends Node

signal state_entered
signal state_finished(next_state: String)


func _enter(params: Dictionary = {}) -> void:
	pass
	

func _exit() -> void:
	pass
	

func handle_input(_event):
	pass	


func physics_update(_delta):
	pass
	
func update(_delta):
	pass
	

func _on_animation_finished(name: String):
	pass
