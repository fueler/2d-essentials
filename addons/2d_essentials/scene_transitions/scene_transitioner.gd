class_name GodotEssentialsSceneTransitioner extends Node


enum AVAILABLE_TRANSITIONS {
	FADE_IN,
	FADE_OUT
}

var fade_scene: PackedScene = preload("res://addons/2d_essentials/scene_transitions/prefab_scenes/fade.tscn")

var PREFAB_SCENES: Dictionary = {
	AVAILABLE_TRANSITIONS.FADE_IN: {
		"scene": fade_scene,
		"parameters": {"animation": "fade_in"}
	},
	AVAILABLE_TRANSITIONS.FADE_OUT: {
		"scene": fade_scene,
		"parameters": {"animation": "fade_out"}
	}
}


func transition_to(scene, transition: AVAILABLE_TRANSITIONS, data: Dictionary = {}) -> void:
	var transition_scene_data = PREFAB_SCENES[transition]
	var transition_scene = transition_scene_data["scene"].instantiate() as GodotEssentialsSceneTransition
	
	transition_scene_data["parameters"].merge(data)
	transition_scene.data = transition_scene_data["parameters"]
	get_viewport().add_child(transition_scene)
	
	await transition_scene.finished_transition
	
	if typeof(scene) == TYPE_STRING and _scene_is_available(scene):
		_change_to_file(scene)
		return
		
	if scene is PackedScene:
		_change_to_packed(scene)


func _change_to_packed(scene: PackedScene) -> void:
	get_tree().change_scene_to_packed(scene)
	
	
func _change_to_file(path: String) -> void:
	get_tree().change_scene_to_file(path)


func _scene_is_available(path: String) -> bool:
	return FileAccess.file_exists(path) or ResourceLoader.exists(path)
