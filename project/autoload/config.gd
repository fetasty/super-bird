extends Node

const CONFIG_FILE_PATH = "user://config.cfg"
const GAME_SECTION = "game"

var config_file = ConfigFile.new()

# TODO 配置部分需要整理, 所有配置项的默认值应该写在 游戏编码 文件中, 而不是存储到配置文件里
# TODO 需要存储到文件的仅仅是用户的设置项, 存档数据等

func _ready() -> void:
	_load_config()


func get_value(key: String, default: Variant = null) -> Variant:
	if not config_file.has_section_key(GAME_SECTION, key):
		set_value(key, default)
	return config_file.get_value(GAME_SECTION, key, default)


func set_value(key: String, value: Variant) -> void:
	config_file.set_value(GAME_SECTION, key, value)
	# save_config()


func _load_config() -> void:
	if FileAccess.file_exists(CONFIG_FILE_PATH):
		var err = config_file.load(CONFIG_FILE_PATH)
		if err != OK:
			Logger.error("Load config file failed!", "main", err)
	else:
		Logger.info("Config file not exists")


func save_config() -> void:
	var err = config_file.save(CONFIG_FILE_PATH)
	if err != OK:
		Logger.error("Save config file failed!", "main", err)
