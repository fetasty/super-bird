extends Node

signal config_changed(key: String, value: Variant)
signal data_changed(key: String, value: Variant)

const _DEFAULT_CONFIG: Dictionary = {
	"gravity": 800.0,
	"jump_velocity": 170.0,
	"max_jump_time": 0.2,
	"fall_degress": 10.0,
	"jump_degress": -10.0,
	"barrier_spawn_time": 1.0,
	"barrier_speed": 120.0,
	"barrier_score_pos": 0.4,
	"barrier_release_pos": -10.0,
	"barrier_passage_width": 70.0,
	"barrier_upper_size_min": 5,
	"barrier_upper_size_max": 35,
	"game_layer_scale": 2.0,
	"level_time": [10.0, 20.0, 30.0],
	"level_gravity": [850.0, 900.0, 950.0],
	"level_barrier_spawn_time": [0.9, 0.8, 0.7],
	"level_barrier_speed": [130.0, 150.0, 170.0],
	"buff_time": {"double_score": 20.0, "saw": 15.0, "shield": 10.0},
}
const _DEFAULT_DATA: Dictionary = {
	"audio_mute": false,
	"audio_volume": 0.5,
	"last_player_role": "chick", # chick, pig, dog
}
const _SAVE_FILE_PATH = "user://save.cfg"
const _GAME_SECTION = "game"

var _game_config: Dictionary
var _barrier_res: Dictionary
var _player_res: Dictionary
var _item_res: Dictionary
var _save_file = ConfigFile.new()
var _save_data_updated: bool = false


func _ready() -> void:
	reset_config()
	_load_data()
	_init_barrier_res()
	_init_player_res()
	_init_item_res()


func _exit_tree() -> void:
	if _save_data_updated:
		save_data()


func reset_config() -> void:
	_game_config = _DEFAULT_CONFIG.duplicate()


func get_config(key: String) -> Variant:
	return _game_config[key]


func set_config(key: String, value: Variant) -> void:
	if key not in _game_config:
		Logger.warn("Try to set config key that not exist: %s" % key)
	if _game_config.get(key, null) == value:
		return
	_game_config[key] = value
	config_changed.emit(key, value)


func get_data(key: String, default: Variant = null) -> Variant:
	return _save_file.get_value(_GAME_SECTION, key, default)


func set_data(key: String, value: Variant) -> void:
	if value == _save_file.get_value(_GAME_SECTION, key):
		return
	_save_file.set_value(_GAME_SECTION, key, value)
	_save_data_updated = true
	data_changed.emit(key, value)


func save_data() -> void:
	_save_data_updated = false
	var err = _save_file.save(_SAVE_FILE_PATH)
	if err != OK:
		Logger.error("Save data failed!", "main", err)


func random_barrier_res() -> BarrierResource:
	var max_rate = 0.0
	for key in _barrier_res:
		var rate = _barrier_res[key].rate
		max_rate += rate
	var rand = randf_range(0.0, max_rate)
	for key in _barrier_res:
		var rate = _barrier_res[key].rate
		rand -= rate
		if rand <= 0.0:
			return _barrier_res[key]
	assert(false, "Invalid barrier res.")
	return null


func random_item_res() -> ItemResource:
	var max_rate = 0.0
	for key in _item_res:
		var rate = _item_res[key].rate
		max_rate += rate
	var rand = randf_range(0.0, max_rate)
	for key in _item_res:
		var rate = _item_res[key].rate
		rand -= rate
		if rand <= 0.0:
			return _item_res[key]
	assert(false, "Invalid item res.")
	return null


func player_res_dict() -> Dictionary:
	return _player_res


func last_selected_player_res() -> PlayerResource:
	var key = get_data("last_player_role")
	return _player_res[key]


func _load_data() -> void:
	if FileAccess.file_exists(_SAVE_FILE_PATH):
		var err = _save_file.load(_SAVE_FILE_PATH)
		if err != OK:
			Logger.error("Load save data failed!", "main", err)
	for key in _DEFAULT_DATA:
		if not _save_file.has_section_key(_GAME_SECTION, key):
			_save_file.set_value(_GAME_SECTION, key, _DEFAULT_DATA[key])
			_save_data_updated = true


func _init_barrier_res() -> void:
	var base_dir = "res://barrier/resource"
	var barrier_res_arr = ResourceLoader.list_directory(base_dir)
	for res_path in barrier_res_arr:
		var path = base_dir + "/" + res_path
		var res := ResourceLoader.load(path) as BarrierResource
		_barrier_res[res.key] = res


func _init_player_res() -> void:
	var base_dir = "res://player/resource"
	var player_res_arr = ResourceLoader.list_directory(base_dir)
	for res_path in player_res_arr:
		var path = base_dir + "/" + res_path
		var res := ResourceLoader.load(path) as PlayerResource
		_player_res[res.key] = res


func _init_item_res() -> void:
	var base_dir = "res://items/resource"
	var item_res_arr = ResourceLoader.list_directory(base_dir)
	for res_path in item_res_arr:
		var path = base_dir + "/" + res_path
		var res := ResourceLoader.load(path) as ItemResource
		_item_res[res.key] = res


func _create_autosave_timer() -> void:
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.autostart = false
	timer.timeout.connect(_autosave_check)
	add_child(timer)
	timer.start()


func _autosave_check() -> void:
	if _save_data_updated:
		Logger.info("Autosave game data.")
		save_data()
