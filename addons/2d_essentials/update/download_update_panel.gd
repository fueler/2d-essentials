@tool

extends Control

const TEMPORARY_FILE_NAME = "user://2d_essentials_temp.zip"

@onready var available_version_download_label = %Label
@onready var download_version_button = %DownloadVersionButton

var next_version_release: Dictionary:
	set(value):
		next_version_release = value
		available_version_download_label.text = value.tag_name.substr(1) + " is available for download"
	get:
		return next_version_release


func _on_read_releases_notes_button_pressed():
	OS.shell_open(next_version_release.html_url)
