extends Node2D


signal level_changed(gravity: float, barrier_spawn_time: float, barrier_speed: float)

var _level_times: Array[float] = [10.0, 20.0, 30.0]
var _level_gravites: Array[float] = [850.0, 900.0, 950.0]
var _level_barrier_spawn_time: Array[float] = [0.9, 0.8, 0.7]
var _level_barrier_speed: Array[float] = [130.0, 150.0, 170.0]

var _cur_game_time: float = 0.0
var _count_time: bool = false


func _process(delta: float) -> void:
	if _count_time:
		var last_game_time: float = _cur_game_time
		_cur_game_time += delta
		for i in range(0, 3):
			if last_game_time < _level_times[i] and _cur_game_time >= _level_times[i]:
				level_changed.emit(_level_gravites[i], _level_barrier_spawn_time[i], _level_barrier_speed[i])


func game_restart() -> void:
	_cur_game_time = 0.0


func game_pause() -> void:
	_count_time = false


func game_resume() -> void:
	_count_time = true
