extends Node2D


var _level_time: Array
var _level_gravity: Array
var _level_barrier_spawn_time: Array
var _level_barrier_speed: Array

var _cur_game_time: float = 0.0
var _count_time: bool = false


func _ready() -> void:
	_load_config()


func _process(delta: float) -> void:
	if _count_time:
		var last_game_time: float = _cur_game_time
		_cur_game_time += delta
		for i in range(0, _level_time.size()):
			if last_game_time < _level_time[i] and _cur_game_time >= _level_time[i]:
				change_level(i)


func change_level(index: int) -> void:
	var gravity = _level_gravity[index]
	var barrier_spawn_time = _level_barrier_spawn_time[index]
	var barrier_speed = _level_barrier_speed[index]
	Logger.info("Level changed: gravity(%s), barrier_spawn_time(%s), barrier_speed(%s)" % [gravity, barrier_spawn_time, barrier_speed])
	GameData.set_config("barrier_speed", barrier_speed)
	GameData.set_config("barrier_spawn_time", barrier_spawn_time)
	GameData.set_config("bird_gravity", gravity)


func game_reset() -> void:
	_cur_game_time = 0.0


func game_pause() -> void:
	_count_time = false


func game_resume() -> void:
	_count_time = true


func _load_config() -> void:
	_level_time = GameData.get_config("level_time")
	_level_gravity = GameData.get_config("level_gravity")
	_level_barrier_spawn_time = GameData.get_config("level_barrier_spawn_time")
	_level_barrier_speed = GameData.get_config("level_barrier_speed")
