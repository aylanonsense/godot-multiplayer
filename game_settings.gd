class_name GameSettings


static func get_default_port() -> int:
	return ProjectSettings.get_setting("game_settings/networking/default_port", -1)
