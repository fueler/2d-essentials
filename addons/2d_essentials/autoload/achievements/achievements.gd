class_name GodotEssentialsPluginAchievements extends Node

signal achievement_unlocked(achievement: Dictionary)
signal all_achievements_unlocked

@onready var http_request: HTTPRequest = $HTTPRequest

@onready var SETTINGS_PATH = "{project_name}/config/achievements".format({"project_name": ProjectSettings.get_setting("application/config/name")})

var current_achievements: Array[Dictionary] = []
var unlocked_achievements: Array[Dictionary] = []
var locked_achievements: Array[Dictionary] = []


func _ready():
	http_request.request_completed.connect(_on_request_completed)
	_create_save_directory(ProjectSettings.get_setting(SETTINGS_PATH + "/save_directory"))
	_prepare_achievements()


func _create_save_directory(path: String) -> void:
	DirAccess.make_dir_absolute(path)


func _prepare_achievements() -> void:
	var local_source_file = _local_source_file_path()
	
	if FileAccess.file_exists(local_source_file):
		var content = JSON.parse_string(FileAccess.get_file_as_string(local_source_file))
		if content == null:
			push_error("GodotEssentials2DPlugin: Failed reading achievement file {path}".format({"path": local_source_file}))
			return
			
		current_achievements.append_array(content)
		
	if GodotEssentialsHelpers.is_valid_url(_remote_source_url()):
		http_request.request(_remote_source_url())
	
	sync_achievements()
		

func sync_achievements() -> void:
	var saved_file_path = _encrypted_save_file_path()
	
	if FileAccess.file_exists(saved_file_path):
		var content = FileAccess.open_encrypted_with_pass(saved_file_path, FileAccess.READ, _get_password())
		if content == null:
			push_error("GodotEssentials2DPlugin: Failed reading saved achievement file {path}".format({"path": saved_file_path}))
			return
			
		var achievements = JSON.parse_string(content.get_as_text())
		if achievements:
			current_achievements = achievements


func _local_source_file_path() -> String:
	return ProjectSettings.get_setting(SETTINGS_PATH + "/local_source")


func _remote_source_url() -> String:
	return ProjectSettings.get_setting(SETTINGS_PATH + "/remote_source")


func _encrypted_save_file_path() -> String:
	return "{dir}/{file}".format({
		"dir": ProjectSettings.get_setting(SETTINGS_PATH + "/save_directory"),
		"file": ProjectSettings.get_setting(SETTINGS_PATH + "/save_file_name")
	})


func _get_password() -> String:
	return ProjectSettings.get_setting(SETTINGS_PATH + "/password")


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result == HTTPRequest.RESULT_SUCCESS:
		var content = JSON.parse_string(body.get_string_from_utf8())
		if content:
			current_achievements.append_array(content)
		return
	
	push_error("GodotEssentials2DPlugin: Failed request with code {code} to remote source url from achievements: {body}".format({"body": body, "code": response_code}))
	
