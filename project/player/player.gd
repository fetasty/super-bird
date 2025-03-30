extends Node2D

## 碰撞了空气墙
signal player_collided_with_wall


var buff_status = {
	"saw": false,
	"double_score": false,
	"shield": false,
}
var _buff_time = {
	"saw": 0.0,
	"double_score": 0.0,
	"shield": 0.0,
}
var _buff_tween = {
	"saw": null,
	"double_score": null,
	"shield": null,
}
var _buff_obj = {}
## 重力加速度
var _gravity = 800.0
## 跳跃速度
var _jump_velocity = 150.0
## 最长保持跳跃时间
var _max_jump_time = 0.2

var _game_layer_scale: float = 2.0

var _fall_degress = 10.0
var _jump_degrees = -10.0

var _velocity = 0.0
var _is_jumping = false


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer
@onready var saw_buff: Sprite2D = $SawBuff
@onready var double_buff: Sprite2D = $DoubleBuff
@onready var shield_buff: Sprite2D = $ShieldBuff
@onready var area_2d: Area2D = $Area2D


func _ready() -> void:
	_load_config()
	GameData.config_changed.connect(_on_config_changed)
	GameData.data_changed.connect(_on_data_changed)
	area_2d.set_meta("player", self)
	_buff_obj["double_score"] = double_buff
	_buff_obj["saw"] = saw_buff
	_buff_obj["shield"] = shield_buff


func _process(delta: float) -> void:
	saw_buff.rotation_degrees += delta * 360.0
	if saw_buff.rotation_degrees > 360.0:
		saw_buff.rotation_degrees -= 360.0
	_update_buff(delta)


func _physics_process(delta: float) -> void:
	if _is_jumping:
		_velocity = -_jump_velocity
	else:
		_velocity += _gravity * delta
	if _velocity > 0:
		sprite_2d.rotation_degrees = _fall_degress
	else:
		sprite_2d.rotation_degrees = _jump_degrees
	position.y += _velocity * delta
	if position.y < -10:
		player_collided_with_wall.emit()
		AudioPlayer.play_hit()
	elif position.y > get_viewport_rect().size.y / _game_layer_scale + 10:
		player_collided_with_wall.emit()
		AudioPlayer.play_hit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		_is_jumping = true
		timer.start()
		AudioPlayer.play_jump()
	if event.is_action_released("jump"):
		_is_jumping = false
		timer.stop()


func reset() -> void:
	_load_config()
	timer.stop()
	_is_jumping = false
	_velocity = 0.0
	buff_status = {
		"saw": false,
		"double_score": false,
		"shield": false,
	}
	_buff_time = {
		"saw": 0.0,
		"double_score": 0.0,
		"shield": 0.0,
	}
	double_buff.visible = false
	saw_buff.visible = false
	shield_buff.visible = false


func add_buff(buff: String) -> void:
	_buff_time[buff] = GameData.get_config("buff_time")[buff]
	buff_status[buff] = true
	match buff:
		"saw":
			saw_buff.visible = true
		"double_score":
			double_buff.visible = true
		"shield":
			shield_buff.visible = true
		_:
			pass


func _remove_buff(buff: String) -> void:
	_buff_time[buff] = 0.0
	buff_status[buff] = false
	match buff:
		"saw":
			saw_buff.visible = false
		"double_score":
			double_buff.visible = false
		"shield":
			shield_buff.visible = false
		_:
			pass


func _update_buff(delta: float) -> void:
	for buff in _buff_time:
		if _buff_time[buff] > 0.0:
			if _buff_time[buff] >= 3.0 and _buff_time[buff] - delta < 3.0:
				if _buff_tween[buff]:
					Logger.info("Buff %s resume!" % buff)
					_buff_tween[buff].play()
				else:
					var tween = get_tree().create_tween().set_loops()
					tween.tween_property(_buff_obj[buff], "self_modulate:a", 0.1, 0.1)
					tween.tween_property(_buff_obj[buff], "self_modulate:a", 1.0, 0.3)
					tween.tween_callback(func ():
						if _buff_time[buff] > 3.0 or not buff_status[buff] or _buff_time[buff] <= 0.0:
							tween.stop()
							Logger.info("Buff %s stop!" % buff)
					)
					Logger.info("Buff %s create!" % buff)
					_buff_tween[buff] = tween
			_buff_time[buff] -= delta
			if _buff_time[buff] <= 0.0:
				_remove_buff(buff)


func _change_gravity(gravity: float) -> void:
	_gravity = gravity


func _load_config() -> void:
	_gravity = GameData.get_config("gravity")
	_jump_velocity = GameData.get_config("jump_velocity")
	_max_jump_time = GameData.get_config("max_jump_time")
	_fall_degress = GameData.get_config("fall_degress")
	_jump_degrees = GameData.get_config("jump_degress")
	_game_layer_scale = GameData.get_config("game_layer_scale")
	timer.wait_time = _max_jump_time
	_load_res()


func _load_res() -> void:
	var res := GameData.last_selected_player_res()
	var res_scale = res.scale
	sprite_2d.texture = res.texture
	sprite_2d.scale = Vector2(res_scale, res_scale)


func _on_config_changed(key: String, value: Variant) -> void:
	match key:
		"gravity":
			_change_gravity(value)
		_:
			pass


func _on_data_changed(key: String, _value: Variant) -> void:
	match key:
		"last_player_role":
			_load_res()
		_:
			pass


func _on_timer_timeout() -> void:
	_is_jumping = false


# TODO delete?
#func _on_area_2d_area_entered(area: Area2D) -> void:
	#AudioPlayer.play_hit()
	#var area_type = area.get_meta("type", "unknown")
	#match area_type:
		#"barrier_iron":
			#if not buff_status.shield:
				#collided.emit()
		#"barrier_wood":
			#if not (buff_status.shield or buff_status.saw):
				#collided.emit()
		#"barrier_grass":
			#pass
		#_:
			#pass
