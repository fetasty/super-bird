extends Sprite2D

## 发生了碰撞
signal collided

## 重力加速度
var _gravity = 800.0
## 跳跃速度
var _jump_velocity = 150.0
## 最长保持跳跃时间
var _max_jump_time = 0.2

var _game_layer_scale: float = 2.0

var _fall_degress = 10.0
var _jump_degrees = -10.0
var _bird_scale = 0.75

var _velocity = 0.0
var _is_jumping = false

@onready var timer: Timer = $Timer


func _ready() -> void:
	_load_config()
	GameData.config_changed.connect(_on_config_changed)


func _physics_process(delta: float) -> void:
	if _is_jumping:
		_velocity = -_jump_velocity
	else:
		_velocity += _gravity * delta
	if _velocity > 0:
		rotation_degrees = _fall_degress
	else:
		rotation_degrees = _jump_degrees
	position.y += _velocity * delta
	if position.y < -10:
		collided.emit()
		AudioPlayer.play_hit()
	elif position.y > get_viewport_rect().size.y / _game_layer_scale + 10:
		collided.emit()
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


func _change_gravity(gravity: float) -> void:
	_gravity = gravity


func _load_config() -> void:
	_gravity = GameData.get_config("bird_gravity")
	_jump_velocity = GameData.get_config("bird_jump_velocity")
	_max_jump_time = GameData.get_config("bird_max_jump_time")
	_fall_degress = GameData.get_config("bird_fall_degress")
	_jump_degrees = GameData.get_config("bird_jump_degress")
	_bird_scale = GameData.get_config("bird_scale")
	_game_layer_scale = GameData.get_config("game_layer_scale")
	timer.wait_time = _max_jump_time
	scale = Vector2(_bird_scale, _bird_scale)


func _on_config_changed(key: String, value: Variant) -> void:
	match key:
		"bird_gravity":
			_change_gravity(value)
		_:
			pass


func _on_timer_timeout() -> void:
	_is_jumping = false


func _on_area_2d_area_entered(_area: Area2D) -> void:
	collided.emit()
	AudioPlayer.play_hit()
