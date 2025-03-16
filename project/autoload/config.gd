extends Node

const CONFIG_FILE_PATH = "user://config.cfg"
const GAME_SECTION = "game"

var config_file = ConfigFile.new()


func _ready() -> void:
	_load_config()


func get_value(key: String, default: Variant = null) -> Variant:
	if not config_file.has_section_key(GAME_SECTION, key):
		set_value(key, default)
	return config_file.get_value(GAME_SECTION, key, default)


func set_value(key: String, value: Variant) -> void:
	config_file.set_value(GAME_SECTION, key, value)
	_save_config()


func _load_config() -> void:
	if FileAccess.file_exists(CONFIG_FILE_PATH):
		var err = config_file.load(CONFIG_FILE_PATH)
		if err != OK:
			Logger.error("Load config file failed!", "main", err)
	else:
		Logger.info("Config file not exists")


func _save_config() -> void:
	var err = config_file.save(CONFIG_FILE_PATH)
	if err != OK:
		Logger.error("Save config file failed!", "main", err)
