@tool

extends Button

const REMOTE_RELEASES_URL = "https://api.github.com/repos/godotessentials/2d-essentials/releases"
const ADDON_LOCAL_CONFIG_PATH = "res://addons/2d_essentials/plugin.cfg"


@onready var http_request: HTTPRequest = $HTTPRequest

func _ready():
	check_for_update()

func check_for_update() -> void:
	http_request.request(REMOTE_RELEASES_URL)


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		return
	
	var response = JSON.parse_string(body.get_string_from_utf8())
	
	if response and typeof(response) == TYPE_ARRAY:
		var current_plugin_version: String = get_plugin_version()
		var latest_version = latest_release_version(response as Array, current_plugin_version)

func latest_release_version(content: Array, current_version: String):
	var versions = content.filter(func(release):
		var version: String = release.tag_name.substr(1)
		return version_to_number(version) > version_to_number(current_version)
	)
	
	if versions.size() > 0:
		return versions[0]
	

func get_plugin_version() -> Variant:
	var config: ConfigFile = ConfigFile.new()
	config.load(ADDON_LOCAL_CONFIG_PATH)

	return config.get_value("plugin", "version")

func version_to_number(version: String) -> int:
	var bits = version.split(".")
	return bits[0].to_int() * 1000000 + bits[1].to_int() * 1000 + bits[2].to_int()
