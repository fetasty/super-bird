extends Control

signal guide_confirmed

var _guide_player_jump_speed: float = -170.0
var _guide_player_gravity: float = 900.0
var _guide_player_jump_y: float = 150.5

var _guide_player_velocity: float = 0.0
var _guide_player_jump_time: float = 0.0

@onready var guide_player: TextureRect = $Guide1/GuidePlayer


func _ready() -> void:
	_guide_player_jump_y = guide_player.position.y


func _process(delta: float) -> void:
	if _guide_player_jump_time > 0:
		_guide_player_jump_time -= delta
		_guide_player_velocity = _guide_player_jump_speed
	else:
		_guide_player_velocity += delta * _guide_player_gravity
	guide_player.position.y += _guide_player_velocity * delta
	if guide_player.position.y > _guide_player_jump_y:
		_guide_player_jump_time = 0.2


func _on_button_pressed() -> void:
	self.visible = false
	guide_confirmed.emit()
